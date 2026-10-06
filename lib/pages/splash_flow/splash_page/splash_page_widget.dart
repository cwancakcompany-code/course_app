import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'splash_page_model.dart';
export 'splash_page_model.dart';

class SplashPageWidget extends StatefulWidget {
  const SplashPageWidget({super.key});

  static String routeName = 'SplashPage';
  static String routePath = '/splashPage';

  @override
  State<SplashPageWidget> createState() => _SplashPageWidgetState();
}

class _SplashPageWidgetState extends State<SplashPageWidget>
    with TickerProviderStateMixin {
  late SplashPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      while (true) {
        if (FFAppState().connected) {
          await Future.delayed(
            Duration(
              milliseconds: 3000,
            ),
          );
          await actions.getCountryCodeLocal();
          _model.currencyAdd = await actions.getCurrencySymbol(
            'USD',
          );
          FFAppState().currencyType = _model.currencyAdd!;
          FFAppState().update(() {});
          if (FFAppState().isIntro == true) {
            if (FFAppState().isLogin == true) {
              context.goNamed(HomeMainPageWidget.routeName);
            } else {
              context.goNamed(
                SignInPageWidget.routeName,
                queryParameters: {
                  'isInner': serializeParam(
                    false,
                    ParamType.bool,
                  ),
                }.withoutNulls,
              );
            }
          } else {
            context.goNamed(OnboardingPageWidget.routeName);
          }

          break;
        } else {
          await Future.delayed(
            Duration(
              milliseconds: 3000,
            ),
          );
          await action_blocks.internetSnackbar(context);
          safeSetState(() {});
        }
      }
    });

    animationsMap.addAll({
      'imageOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(-2.0, -2.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.asset(
                  'assets/images/Group_1171277899.png',
                  width: 180.0,
                  height: 180.0,
                  fit: BoxFit.contain,
                ),
              ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation']!),
            ].divide(SizedBox(height: 4.0)),
          ),
        ),
      ),
    );
  }
}
