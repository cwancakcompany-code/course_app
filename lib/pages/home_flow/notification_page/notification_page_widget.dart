import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/pages/components/notification_component/notification_component_widget.dart';
import '/pages/empty_components/no_notification_component/no_notification_component_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'notification_page_model.dart';
export 'notification_page_model.dart';

class NotificationPageWidget extends StatefulWidget {
  const NotificationPageWidget({super.key});

  static String routeName = 'NotificationPage';
  static String routePath = '/notificationPage';

  @override
  State<NotificationPageWidget> createState() => _NotificationPageWidgetState();
}

class _NotificationPageWidgetState extends State<NotificationPageWidget> {
  late NotificationPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationPageModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: 'Notifications',
                  isBack: false,
                  isEdit: false,
                  backAction: () async {},
                  editAction: () async {},
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (FFAppState().connected) {
                      return Builder(
                        builder: (context) {
                          if (FFAppState().isLogin == true) {
                            return Builder(
                              builder: (context) {
                                final notificationList =
                                    FFAppState().notificationsList.toList();

                                return ListView.separated(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    20.0,
                                    0,
                                    20.0,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  itemCount: notificationList.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 16.0),
                                  itemBuilder:
                                      (context, notificationListIndex) {
                                    final notificationListItem =
                                        notificationList[notificationListIndex];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: wrapWithModel(
                                        model: _model
                                            .notificationComponentModels
                                            .getModel(
                                          notificationListItem.title,
                                          notificationListIndex,
                                        ),
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: NotificationComponentWidget(
                                          key: Key(
                                            'Keyj3x_${notificationListItem.title}',
                                          ),
                                          title: notificationListItem.title,
                                          description:
                                              notificationListItem.subTitle,
                                          createAt:
                                              notificationListItem.createAt,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return wrapWithModel(
                              model: _model.noNotificationComponentModel,
                              updateCallback: () => safeSetState(() {}),
                              child: NoNotificationComponentWidget(
                                callBack: () async {
                                  context.goNamed(HomeMainPageWidget.routeName);
                                },
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      return Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Lottie.asset(
                          'assets/jsons/No_Wifi.json',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.contain,
                          animate: true,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
