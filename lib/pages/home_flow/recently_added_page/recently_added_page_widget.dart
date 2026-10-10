import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'recently_added_page_model.dart';
export 'recently_added_page_model.dart';

class RecentlyAddedPageWidget extends StatefulWidget {
  const RecentlyAddedPageWidget({super.key});

  static String routeName = 'RecentlyAddedPage';
  static String routePath = '/recentlyAddedPage';

  @override
  State<RecentlyAddedPageWidget> createState() =>
      _RecentlyAddedPageWidgetState();
}

class _RecentlyAddedPageWidgetState extends State<RecentlyAddedPageWidget>
    with TickerProviderStateMixin {
  late RecentlyAddedPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecentlyAddedPageModel());

    animationsMap.addAll({
      'mainComponentOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: null,
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: 'Recently Added',
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
                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          20.0,
                          0,
                          20.0,
                        ),
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 0.0, 20.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final recom =
                                    FFAppState().recommendedForYouList.toList();

                                return Wrap(
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  direction: Axis.horizontal,
                                  runAlignment: WrapAlignment.start,
                                  verticalDirection: VerticalDirection.down,
                                  clipBehavior: Clip.none,
                                  children:
                                      List.generate(recom.length, (recomIndex) {
                                    final recomItem = recom[recomIndex];
                                    return wrapWithModel(
                                      model:
                                          _model.mainComponentModels.getModel(
                                        recomIndex.toString(),
                                        recomIndex,
                                      ),
                                      updateCallback: () => safeSetState(() {}),
                                      child: MainComponentWidget(
                                        key: Key(
                                          'Keyxys_${recomIndex.toString()}',
                                        ),
                                        image: recomItem.image,
                                        name: recomItem.title,
                                        price: recomItem.price,
                                        review: recomItem.rating.toStringAsFixed(1),
                                        profilePath: recomItem.profileImage,
                                        instructorName:
                                            recomItem.instructorName,
                                        subname: recomItem.subtitle,
                                        width: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              810.0) {
                                            return double.infinity;
                                          } else if ((MediaQuery.sizeOf(context)
                                                      .width >=
                                                  810.0) &&
                                              (MediaQuery.sizeOf(context)
                                                      .width <
                                                  1280.0)) {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    56) *
                                                1 /
                                                2);
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width >=
                                              1280.0) {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    88) *
                                                1 /
                                                4);
                                          } else {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    104) *
                                                1 /
                                                5);
                                          }
                                        }(),
                                        subject: recomItem.subject,
                                        onTap: () async {
                                          context.pushNamed(
                                            CourseDetailPageWidget.routeName,
                                            queryParameters: {
                                              'detail': serializeParam(
                                                recomItem,
                                                ParamType.DataStruct,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                      ),
                                    ).animateOnPageLoad(
                                      animationsMap[
                                          'mainComponentOnPageLoadAnimation']!,
                                      effects: [
                                        MoveEffect(
                                          curve: Curves.easeInOut,
                                          delay: valueOrDefault<double>(
                                            recomIndex * 111,
                                            0.0,
                                          ).ms,
                                          duration: 300.0.ms,
                                          begin: Offset(30.0, 0.0),
                                          end: Offset(0.0, 0.0),
                                        ),
                                      ],
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
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
