import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import '/pages/components/row_component/row_component_widget.dart';
import '/pages/dialog_components/filter_sheet/filter_sheet_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'explore_component_model.dart';
export 'explore_component_model.dart';

class ExploreComponentWidget extends StatefulWidget {
  const ExploreComponentWidget({super.key});

  @override
  State<ExploreComponentWidget> createState() => _ExploreComponentWidgetState();
}

class _ExploreComponentWidgetState extends State<ExploreComponentWidget> {
  late ExploreComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExploreComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(SearchPageWidget.routeName);
            },
            child: Container(
              width: double.infinity,
              height: 54.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).lightGray,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SvgPicture.asset(
                    'assets/images/searchBalck.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: Text(
                      'Search here',
                      textAlign: TextAlign.start,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: FlutterFlowTheme.of(context).black40,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.5,
                          ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: FilterSheetWidget(
                              call: () async {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                    child: SvgPicture.asset(
                      'assets/images/filter.svg',
                      width: 24.0,
                      height: 24.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ]
                    .divide(SizedBox(width: 16.0))
                    .addToStart(SizedBox(width: 16.0))
                    .addToEnd(SizedBox(width: 16.0)),
              ),
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (FFAppState().connected) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    16.0,
                    0,
                    16.0,
                  ),
                  scrollDirection: Axis.vertical,
                  children: [
                    Builder(
                      builder: (context) {
                        final catExpList = FFAppState()
                            .categoriesList
                            .toList()
                            .take(8)
                            .toList();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(catExpList.length,
                                    (catExpListIndex) {
                              final catExpListItem =
                                  catExpList[catExpListIndex];
                              return wrapWithModel(
                                model: _model.categoryComponentModels.getModel(
                                  catExpListItem.name,
                                  catExpListIndex,
                                ),
                                updateCallback: () => safeSetState(() {}),
                                child: CategoryComponentWidget(
                                  key: Key(
                                    'Keyjd7_${catExpListItem.name}',
                                  ),
                                  image: catExpListItem.image,
                                  name: catExpListItem.name,
                                  width: 80.0,
                                  tapAction: () async {
                                    final categoryId = catExpListIndex <
                                            FFAppState().categoryIds.length
                                        ? FFAppState()
                                            .categoryIds[catExpListIndex]
                                        : '';
                                    context.pushNamed(
                                      CategoryRelatedPageWidget.routeName,
                                      queryParameters: {
                                        'title': serializeParam(
                                          catExpListItem.name,
                                          ParamType.String,
                                        ),
                                        'categoryId': serializeParam(
                                          categoryId,
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                ),
                              );
                            })
                                .divide(SizedBox(width: 23.0))
                                .addToStart(SizedBox(width: 20.0))
                                .addToEnd(SizedBox(width: 20.0)),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 0.0),
                      child: wrapWithModel(
                        model: _model.rowComponentModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'Recently Added',
                          isShow: true,
                          viewAllAction: () async {
                            context
                                .pushNamed(RecentlyAddedPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                      child: Builder(
                        builder: (context) {
                          final recent = FFAppState()
                              .recommendedForYouList
                              .toList()
                              .take(3)
                              .toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(recent.length, (recentIndex) {
                                final recentItem = recent[recentIndex];
                                return wrapWithModel(
                                  model: _model.mainComponentModels1.getModel(
                                    recentIndex.toString(),
                                    recentIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: MainComponentWidget(
                                    key: Key(
                                      'Keyarp_${recentIndex.toString()}',
                                    ),
                                    image: recentItem.image,
                                    name: recentItem.title,
                                    price: recentItem.price,
                                    review: recentItem.rating.toStringAsFixed(1),
                                    profilePath: recentItem.profileImage,
                                    instructorName: recentItem.instructorName,
                                    subname: recentItem.subtitle,
                                    width: () {
                                      final w =
                                          MediaQuery.sizeOf(context).width;
                                      if (w < kBreakpointSmall) return 178.0;
                                      if (w < kBreakpointMedium) return 192.0;
                                      if (w < kBreakpointLarge) return 208.0;
                                      return 224.0;
                                    }(),
                                    subject: recentItem.subject,
                                    onTap: () async {
                                      context.pushNamed(
                                        CourseDetailPageWidget.routeName,
                                        queryParameters: {
                                          'detail': serializeParam(
                                            recentItem,
                                            ParamType.DataStruct,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                );
                              })
                                      .divide(SizedBox(width: 20.0))
                                      .addToStart(SizedBox(width: 20.0))
                                      .addToEnd(SizedBox(width: 16.0)),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 0.0),
                      child: wrapWithModel(
                        model: _model.rowComponentModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'Suggestion for you',
                          isShow: true,
                          viewAllAction: () async {
                            context.pushNamed(
                                SuggestionForYouPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                      child: Builder(
                        builder: (context) {
                          final recent = FFAppState()
                              .popularCoursesList
                              .toList()
                              .take(3)
                              .toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(recent.length, (recentIndex) {
                                final recentItem = recent[recentIndex];
                                return wrapWithModel(
                                  model: _model.mainComponentModels2.getModel(
                                    recentIndex.toString(),
                                    recentIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: MainComponentWidget(
                                    key: Key(
                                      'Keythi_${recentIndex.toString()}',
                                    ),
                                    image: recentItem.image,
                                    name: recentItem.title,
                                    price: recentItem.price,
                                    review: recentItem.rating.toStringAsFixed(1),
                                    profilePath: recentItem.profileImage,
                                    instructorName: recentItem.instructorName,
                                    subname: recentItem.subtitle,
                                    width: () {
                                      final w =
                                          MediaQuery.sizeOf(context).width;
                                      if (w < kBreakpointSmall) return 178.0;
                                      if (w < kBreakpointMedium) return 192.0;
                                      if (w < kBreakpointLarge) return 208.0;
                                      return 224.0;
                                    }(),
                                    subject: recentItem.subject,
                                    onTap: () async {
                                      context.pushNamed(
                                        CourseDetailPageWidget.routeName,
                                        queryParameters: {
                                          'detail': serializeParam(
                                            recentItem,
                                            ParamType.DataStruct,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                );
                              })
                                      .divide(SizedBox(width: 20.0))
                                      .addToStart(SizedBox(width: 20.0))
                                      .addToEnd(SizedBox(width: 16.0)),
                            ),
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
      ].addToStart(SizedBox(height: 16.0)),
    );
  }
}
