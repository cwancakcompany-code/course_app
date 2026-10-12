import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import '/pages/components/row_component/row_component_widget.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                                        // Modern Styled Top Hero Header Container
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                .alternate
                                .withValues(alpha: 0.7),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primaryText
                                  .withValues(alpha: 0.04),
                              blurRadius: 18.0,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withValues(alpha: 0.03),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting & Notification Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            '👋 ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Expanded(
                                            child: Text(
                                              FFAppState().isLogin
                                                  ? 'Hello, ${FFAppState().userDetail.firstName.isNotEmpty ? FFAppState().userDetail.firstName : 'there'}'
                                                  : 'Welcome to EduMaster',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'SF Pro Display',
                                                    fontSize: 20.0,
                                                    letterSpacing: -0.3,
                                                    fontWeight: FontWeight.bold,
                                                    lineHeight: 1.25,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'What do you want to learn today?',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF Pro Display',
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                              fontSize: 13.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    splashColor: FlutterFlowTheme.of(context)
                                        .primary
                                        .withValues(alpha: 0.12),
                                    onTap: () async {
                                      context.pushNamed(
                                          NotificationPageWidget.routeName);
                                    },
                                    child: Ink(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate
                                              .withValues(alpha: 0.8),
                                          width: 1,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/Frame_1171277789.svg',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.contain,
                                            colorFilter: ColorFilter.mode(
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context)
                                                    .primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                                  width: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Search Bar with Filter Accent
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.0),
                                splashColor: FlutterFlowTheme.of(context)
                                    .primary
                                    .withValues(alpha: 0.08),
                                onTap: () async {
                                  context.pushNamed(SearchPageWidget.routeName);
                                },
                                child: Ink(
                                  width: double.infinity,
                                  height: 48.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate
                                          .withValues(alpha: 0.8),
                                      width: 1.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        size: 21,
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Search courses, topics, mentors…',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF Pro Display',
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/images/filter.svg',
                                          width: 15.0,
                                          height: 15.0,
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            FlutterFlowTheme.of(context).primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                    width: 72.0,
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
                                  .divide(SizedBox(width: 12.0))
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
                                    review:
                                        recomItem.rating.toStringAsFixed(1),
                                    profilePath: recomItem.profileImage,
                                    instructorName: recomItem.instructorName,
                                    subname: recomItem.subtitle,
                                    width: () {
                                      final w = MediaQuery.sizeOf(context).width;
                                      if (w < kBreakpointSmall) return 178.0;
                                      if (w < kBreakpointMedium) return 192.0;
                                      if (w < kBreakpointLarge) return 208.0;
                                      return 224.0;
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
                                      .divide(SizedBox(width: 14.0))
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
                                    review:
                                        recomItem.rating.toStringAsFixed(1),
                                    profilePath: recomItem.profileImage,
                                    instructorName: recomItem.instructorName,
                                    subname: recomItem.subtitle,
                                    width: () {
                                      final w = MediaQuery.sizeOf(context).width;
                                      if (w < kBreakpointSmall) return 178.0;
                                      if (w < kBreakpointMedium) return 192.0;
                                      if (w < kBreakpointLarge) return 208.0;
                                      return 224.0;
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
                                      .divide(SizedBox(width: 14.0))
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
                        model: _model.rowComponentModelAllCourses,
                        updateCallback: () => safeSetState(() {}),
                        child: RowComponentWidget(
                          title: 'All Courses',
                          isShow: true,
                          viewAllAction: () async {
                            context.pushNamed(AllCoursesPageWidget.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                      child: Builder(
                        builder: (context) {
                          final allCourses = FFAppState()
                              .allCoursesList
                              .toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(allCourses.length, (courseIndex) {
                                final courseItem = allCourses[courseIndex];
                                return wrapWithModel(
                                  model: _model.mainComponentModelsAllCourses.getModel(
                                    courseIndex.toString(),
                                    courseIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: MainComponentWidget(
                                    key: Key(
                                      'KeyAllCourse_${courseIndex.toString()}',
                                    ),
                                    image: courseItem.image,
                                    name: courseItem.title,
                                    price: courseItem.price,
                                    review:
                                        courseItem.rating.toStringAsFixed(1),
                                    profilePath: courseItem.profileImage,
                                    instructorName: courseItem.instructorName,
                                    subname: courseItem.subtitle,
                                    width: () {
                                      final w = MediaQuery.sizeOf(context).width;
                                      if (w < kBreakpointSmall) return 178.0;
                                      if (w < kBreakpointMedium) return 192.0;
                                      if (w < kBreakpointLarge) return 208.0;
                                      return 224.0;
                                    }(),
                                    subject: courseItem.subject,
                                    onTap: () async {
                                      context.pushNamed(
                                        CourseDetailPageWidget.routeName,
                                        queryParameters: {
                                          'detail': serializeParam(
                                            courseItem,
                                            ParamType.DataStruct,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                );
                              })
                                      .divide(SizedBox(width: 14.0))
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
