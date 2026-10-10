import 'dart:async';

import '/backend/services/auth_service.dart';
import '/backend/supabase/supabase_bootstrap.dart';
import '/backend/ui/app_notify.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'verifications_page_model.dart';
export 'verifications_page_model.dart';

class VerificationsPageWidget extends StatefulWidget {
  const VerificationsPageWidget({
    super.key,
    required this.email,
  });

  final String? email;

  static String routeName = 'VerificationsPage';
  static String routePath = '/verificationsPage';

  @override
  State<VerificationsPageWidget> createState() =>
      _VerificationsPageWidgetState();
}

class _VerificationsPageWidgetState extends State<VerificationsPageWidget> {
  late VerificationsPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _linkController = TextEditingController();
  StreamSubscription<AuthState>? _authSub;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationsPageModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.timerController.onResetTimer();
      _model.timerController.onStartTimer();
    });

    // When Free Tier magic link opens the app, finish signup + go home.
    _authSub = SupabaseBootstrap.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && !_busy) {
        _finishFromSession();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _linkController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _finishFromSession() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AuthService().finalizePendingSignUp();
      if (!mounted) return;
      AppNotify.success(context, 'Account verified. Welcome!');
      context.goNamed(HomeMainPageWidget.routeName);
    } on AuthFailure catch (e) {
      if (mounted) AppNotify.error(context, e.message);
    } catch (_) {
      // Still waiting for a valid session — ignore.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyPastedLink() async {
    if (!FFAppState().connected) {
      await action_blocks.internetSnackbar(context);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService().verifySignUpFromEmailLink(_linkController.text);
      if (!mounted) return;
      AppNotify.success(context, 'Account verified. Welcome!');
      context.goNamed(HomeMainPageWidget.routeName);
    } on AuthFailure catch (e) {
      AppNotify.error(context, e.message);
    } catch (_) {
      AppNotify.error(context, 'Could not verify email link');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: 'Verification',
                  isBack: false,
                  isEdit: false,
                  backAction: () async {},
                  editAction: () async {},
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Text(
                      'ئیمەیڵەکە لینکی magic link دەنێرێت (نەک کۆدی ٦ ژمارەیی).',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        letterSpacing: 0,
                        color: theme.secondaryText,
                        lineHeight: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لینکەکەی نێردراو بۆ ${widget.email} لەم مۆبایلەدا بکەرەوە. '
                      'ئەگەر پەڕەیەکی سپی/بەتاڵ دەرکەوت، بگەڕێرەوە بۆ ئەپەکە و دوگمەی خوارەوە داگرە، '
                      'یان هەموو لینکەکە کۆپی بکە و لێرە بلکێنە.',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF Pro Display',
                        fontSize: 17,
                        letterSpacing: 0,
                        lineHeight: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FFButtonWidget(
                      onPressed: _busy ? null : _finishFromSession,
                      text: _busy ? 'Checking…' : "I've opened the link",
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(
                          fontFamily: 'SF Pro Display',
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Or paste the full email link here',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF Pro Display',
                        fontSize: 15,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _linkController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'https://….supabase.co/auth/v1/verify?…',
                        filled: true,
                        fillColor: theme.lightGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FFButtonWidget(
                      onPressed: _busy ? null : _verifyPastedLink,
                      text: 'Verify pasted link',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 52,
                        color: theme.secondaryBackground,
                        textStyle: theme.titleSmall.override(
                          fontFamily: 'SF Pro Display',
                          color: theme.primaryText,
                          fontSize: 15,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 0,
                        borderSide: BorderSide(color: theme.black20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 28),
                    InkWell(
                      onTap: () async {
                        if (!_model.isShow || _busy) return;
                        try {
                          await AuthService().resendSignUpOtp();
                          _model.timerController.onResetTimer();
                          _model.timerController.onStartTimer();
                          _model.isShow = false;
                          safeSetState(() {});
                          if (!mounted) return;
                          AppNotify.info(
                            context,
                            'A new email was sent',
                            title: 'Email resent',
                          );
                        } on AuthFailure catch (e) {
                          AppNotify.error(context, e.message);
                        } catch (_) {
                          AppNotify.error(context, 'Could not resend email');
                        }
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Didn't get the email? ",
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                fontSize: 16,
                                letterSpacing: 0,
                              ),
                            ),
                            TextSpan(
                              text: 'Resend',
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                color: _model.isShow
                                    ? theme.primary
                                    : theme.secondaryText,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FlutterFlowTimer(
                      initialTime: _model.timerInitialTimeMs,
                      getDisplayTime: (value) => StopWatchTimer.getDisplayTime(
                        value,
                        hours: false,
                        milliSecond: false,
                      ),
                      controller: _model.timerController,
                      updateStateInterval: const Duration(milliseconds: 1000),
                      onChanged: (value, displayTime, shouldUpdate) {
                        _model.timerMilliseconds = value;
                        _model.timerValue = displayTime;
                        if (shouldUpdate) safeSetState(() {});
                      },
                      onEnded: () async {
                        _model.timerController.onStopTimer();
                        _model.isShow = true;
                        safeSetState(() {});
                      },
                      textAlign: TextAlign.center,
                      style: theme.headlineSmall.override(
                        fontFamily: 'SF Pro Display',
                        fontSize: 20,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
