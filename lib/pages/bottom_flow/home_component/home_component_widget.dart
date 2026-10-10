import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import '/pages/components/row_component/row_component_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'home_component_model.dart';
export 'home_component_model.dart';

class HomeComponentWidget extends StatefulWidget {
  const HomeComponentWidget({super.key});

  @override
  State<HomeComponentWidget> createState() => _HomeComponentWidgetState();
}

class _HomeComponentWidgetState extends State<HomeComponentWidget> {
  late HomeComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeComponentModel());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!FFAppState().catalogLoading) {
        try {
          await actions.loadCatalog(forceRefresh: true);
        } catch (_) {}
      }
    });
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
        Expanded(
          child: Builder(
            builder: (context) {
              if (FFAppState().connected) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    16.0,
                    0,
                    24.0,
                  ),
                  scrollDirection: Axis.vertical,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 4.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 90.0,
                                child: CarouselSlider(
                                  items: [
                                    Image.asset(
                                      'assets/images/Group_1171277903.png',
                                      fit: BoxFit.contain,
                                    ),
                                    Image.asset(
                                      'assets/images/Group_1171277903.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                  carouselController:
                                      _model.carouselController ??=
                                          CarouselSliderController(),
                                  options: CarouselOptions(
                                    initialPage: 1,
                                    viewportFraction: 1.0,
                                    disableCenter: true,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.25,
                                    enableInfiniteScroll: true,
                                    scrollDirection: Axis.horizontal,
                                    autoPlay: false,
                                    onPageChanged: (index, _) =>
                                        _model.carouselCurrentIndex = index,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (FFAppState().isLogin)
                                          Text(
                                            'Hello Ronald Richards 👋',
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF Pro Display',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .info,
                                                  fontSize: 20.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        Text(
                                          'Find a source you want to learn',
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF Pro Display',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                fontSize: 17.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                          NotificationPageWidget.routeName);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: SvgPicture.asset(
                                        'assets/images/Frame_1171277789.svg',
                                        width: 24.0,
                                        height: 24.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(SearchPageWidget.routeName);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 56.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
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
                                            'Search...',
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF Pro Display',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .black40,
                                                  fontSize: 17.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 8.0),
                      child: wrapWithModel(
                        model: _model.rowComponentModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'Categories',
                          isShow: true,
                          viewAllAction: () async {
                            context.pushNamed(CategoriesPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                      child: Builder(
                        builder: (context) {
                          final cat = FFAppState()
                              .categoriesList
                              .toList()
                              .take(8)
                              .toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: List.generate(cat.length, (catIndex) {
                                final catItem = cat[catIndex];
                                return wrapWithModel(
                                  model:
                                      _model.categoryComponentModels.getModel(
                                    catItem.name,
                                    catIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryComponentWidget(
                                    key: Key(
                                      'Keyl3m_${catItem.name}',
                                    ),
                                    image: catItem.image,
                                    name: catItem.name,
                                    width: 80.0,
                                    tapAction: () async {
                                      final categoryId = catIndex <
                                              FFAppState().categoryIds.length
                                          ? FFAppState().categoryIds[catIndex]
                                          : '';
                                      context.pushNamed(
                                        CategoryRelatedPageWidget.routeName,
                                        queryParameters: {
                                          'title': serializeParam(
                                            catItem.name,
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
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                      child: wrapWithModel(
                        model: _model.rowComponentModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'Recommended for you',
                          isShow: true,
                          viewAllAction: () async {
                            context.pushNamed(
                                RecommendedForYouPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                      child: Builder(
                        builder: (context) {
                          final recom = FFAppState()
                              .recommendedForYouList
                              .toList()
                              .take(3)
                              .toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(recom.length, (recomIndex) {
                                final recomItem = recom[recomIndex];
                                return wrapWithModel(
                                  model: _model.mainComponentModels1.getModel(
                                    recomIndex.toString(),
                                    recomIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: MainComponentWidget(
                                    key: Key(
                                      'Keym51_${recomIndex.toString()}',
                                    ),
                                    image: recomItem.image,
                                    name: recomItem.title,
                                    price: recomItem.price,
                                    review: recomItem.rating.toString(),
                                    profilePath: recomItem.profileImage,
                                    instructorName: recomItem.instructorName,
                                    subname: recomItem.subtitle,
                                    width: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 287.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 287.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 320.0;
                                      } else {
                                        return 350.0;
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
                                );
                              })
                                      .divide(SizedBox(width: 20.0))
                                      .addToStart(SizedBox(width: 20.0))
                                      .addToEnd(SizedBox(width: 20.0)),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                      child: wrapWithModel(
                        model: _model.rowComponentModel3,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'Popular Courses',
                          isShow: true,
                          viewAllAction: () async {
                            context
                                .pushNamed(PopularCoursesPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                      child: Builder(
                        builder: (context) {
                          final recom = FFAppState()
                              .popularCoursesList
                              .toList()
                              .take(3)
                              .toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(recom.length, (recomIndex) {
                                final recomItem = recom[recomIndex];
                                return wrapWithModel(
                                  model: _model.mainComponentModels2.getModel(
                                    recomIndex.toString(),
                                    recomIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: MainComponentWidget(
                                    key: Key(
                                      'Keyxwb_${recomIndex.toString()}',
                                    ),
                                    image: recomItem.image,
                                    name: recomItem.title,
                                    price: recomItem.price,
                                    review: recomItem.rating.toString(),
                                    profilePath: recomItem.profileImage,
                                    instructorName: recomItem.instructorName,
                                    subname: recomItem.subtitle,
                                    width: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 287.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 287.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 320.0;
                                      } else {
                                        return 350.0;
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
                                );
                              })
                                      .divide(SizedBox(width: 20.0))
                                      .addToStart(SizedBox(width: 20.0))
                                      .addToEnd(SizedBox(width: 20.0)),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                      child: wrapWithModel(
                        model: _model.rowComponentModel4,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'Best Instructor',
                          isShow: true,
                          viewAllAction: () async {
                            context.pushNamed(InstructorPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
                      child: Builder(
                        builder: (context) {
                          final instructut = FFAppState()
                              .instructorList
                              .toList()
                              .take(4)
                              .toList();

                          return Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            runAlignment: WrapAlignment.start,
                            verticalDirection: VerticalDirection.down,
                            clipBehavior: Clip.none,
                            children: List.generate(instructut.length,
                                (instructutIndex) {
                              final instructutItem =
                                  instructut[instructutIndex];
                              return InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                    InstructorDetailPageWidget.routeName,
                                    queryParameters: {
                                      'instructorDetail': serializeParam(
                                        instructutItem,
                                        ParamType.DataStruct,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                child: Container(
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        810.0) {
                                      return ((MediaQuery.sizeOf(context)
                                                  .width -
                                              56) *
                                          1 /
                                          2);
                                    } else if ((MediaQuery.sizeOf(context)
                                                .width >=
                                            810.0) &&
                                        (MediaQuery.sizeOf(context).width <
                                            1280.0)) {
                                      return ((MediaQuery.sizeOf(context)
                                                  .width -
                                              88) *
                                          1 /
                                          4);
                                    } else if (MediaQuery.sizeOf(context)
                                            .width >=
                                        1280.0) {
                                      return ((MediaQuery.sizeOf(context)
                                                  .width -
                                              120) *
                                          1 /
                                          6);
                                    } else {
                                      return ((MediaQuery.sizeOf(context)
                                                  .width -
                                              152) *
                                          1 /
                                          8);
                                    }
                                  }(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color:
                                          FlutterFlowTheme.of(context).black20,
                                    ),
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 7.0, 16.0, 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 48.0,
                                          height: 48.0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: CachedNetworkImage(
                                            fadeInDuration:
                                                Duration(milliseconds: 200),
                                            fadeOutDuration:
                                                Duration(milliseconds: 200),
                                            imageUrl: instructutItem.image,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              'assets/images/error_image.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            instructutItem.name,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF Pro Display',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
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
    );
  }
}
