import '/backend/schema/structs/index.dart';
import '/backend/services/realtime_sync_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'course_about_tab.dart';
import 'course_detail_page_model.dart';
import 'course_lessons_tab.dart';
import 'course_reviews_tab.dart';
export 'course_detail_page_model.dart';

class CourseDetailPageWidget extends StatefulWidget {
  const CourseDetailPageWidget({
    super.key,
    required this.detail,
  });

  final RecommendedForYouModelStruct? detail;

  static String routeName = 'CourseDetailPage';
  static String routePath = '/courseDetailPage';

  @override
  State<CourseDetailPageWidget> createState() => _CourseDetailPageWidgetState();
}

class _CourseDetailPageWidgetState extends State<CourseDetailPageWidget> {
  late CourseDetailPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late VoidCallback _realtimeListener;
  late VoidCallback _curriculumListener;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CourseDetailPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _model.loadCourseDetail(widget.detail?.id);
      if (mounted) safeSetState(() {});
    });

    void reloadIfRelevant(String? updatedCourseId) {
      if (updatedCourseId == null || updatedCourseId == widget.detail?.id) {
        if (mounted) {
          _model.loadCourseDetail(widget.detail?.id).then((_) {
            if (mounted) safeSetState(() {});
          });
        }
      }
    }

    _realtimeListener = () {
      reloadIfRelevant(RealtimeSyncService().courseUpdateNotifier.value);
    };
    _curriculumListener = () {
      reloadIfRelevant(RealtimeSyncService().curriculumUpdateNotifier.value);
    };
    RealtimeSyncService().courseUpdateNotifier.addListener(_realtimeListener);
    RealtimeSyncService()
        .curriculumUpdateNotifier
        .addListener(_curriculumListener);
  }

  @override
  void dispose() {
    RealtimeSyncService().courseUpdateNotifier.removeListener(_realtimeListener);
    RealtimeSyncService()
        .curriculumUpdateNotifier
        .removeListener(_curriculumListener);
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
        body: Builder(
          builder: (context) {
            if (FFAppState().connected) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Stack(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Stack(
                            children: [
                              Hero(
                                tag: (widget.detail?.image ?? '').isNotEmpty
                                    ? widget.detail!.image
                                    : 'course_${widget.detail?.title ?? 'detail'}',
                                transitionOnUserGestures: true,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: Builder(
                                    builder: (context) {
                                      final url =
                                          (widget.detail?.image ?? '').trim();
                                      if (url.isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          height: 332.0,
                                          color: FlutterFlowTheme.of(context)
                                              .black10,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            size: 64,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                        );
                                      }
                                      return CachedNetworkImage(
                                        fadeInDuration:
                                            Duration(milliseconds: 200),
                                        fadeOutDuration:
                                            Duration(milliseconds: 200),
                                        imageUrl: url,
                                        width: double.infinity,
                                        height: 332.0,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                Container(
                                          width: double.infinity,
                                          height: 332.0,
                                          color: FlutterFlowTheme.of(context)
                                              .black10,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            size: 64,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: 0.2,
                                child: Container(
                                  width: double.infinity,
                                  height: 332.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).black,
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 332.0,
                                decoration: BoxDecoration(),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    final videoRef = _model.previewVideoGuid;
                                    if (videoRef.isEmpty) return;
                                    context.pushNamed(
                                      VideoPlayerPageWidget.routeName,
                                      queryParameters: {
                                        'videoUrl': serializeParam(
                                          videoRef,
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: SvgPicture.asset(
                                      'assets/images/play-circle.svg',
                                      width: 40.0,
                                      height: 40.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 62.0, 20.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.safePop();
                                      },
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: SvgPicture.asset(
                                              'assets/images/arrow_left_outline.svg',
                                              width: 24.0,
                                              height: 24.0,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Builder(
                                          builder: (context) => Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 20.0, 0.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await Share.share(
                                                  'Online Learning App',
                                                  sharePositionOrigin:
                                                      getWidgetBoundingBox(
                                                          context),
                                                );
                                              },
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    child: SvgPicture.asset(
                                                      'assets/images/share.svg',
                                                      width: 24.0,
                                                      height: 24.0,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            if (FFAppState().isLogin) {
                                              await action_blocks
                                                  .addAndRemoveFavourite(
                                                context,
                                                isAvilable: FFAppState()
                                                    .favouriteList
                                                    .where((e) =>
                                                        e.title ==
                                                        widget!.detail?.title)
                                                    .toList()
                                                    .isNotEmpty,
                                                product: widget!.detail,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Please log in first',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'SF Pro Display',
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      fontSize: 17.0,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 2000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  action: SnackBarAction(
                                                    label: 'Login',
                                                    textColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    onPressed: () async {
                                                      context.pushNamed(
                                                        SignInPageWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'isInner':
                                                              serializeParam(
                                                            true,
                                                            ParamType.bool,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Builder(
                                              builder: (context) {
                                                if (FFAppState()
                                                    .favouriteList
                                                    .where((e) =>
                                                        e.title ==
                                                        widget!.detail?.title)
                                                    .toList()
                                                    .isNotEmpty) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    child: SvgPicture.asset(
                                                      'assets/images/fav_fill_learning.svg',
                                                      width: 24.0,
                                                      height: 24.0,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  );
                                                } else {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    child: SvgPicture.asset(
                                                      'assets/images/fav_learning.svg',
                                                      width: 24.0,
                                                      height: 24.0,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ].divide(SizedBox(width: 12.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 285.0, 0.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: ListView(
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        30.0,
                                        0,
                                        0,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 0.0, 20.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 28.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 0.0, 12.0, 0.0),
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      widget!.detail?.subject,
                                                      'Subject',
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'SF Pro Display',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          fontSize: 13.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 20.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .black20,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          6.0, 0.0, 6.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/star.svg',
                                                        width: 13.0,
                                                        height: 13.0,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      Text(
                                                        valueOrDefault<String>(
                                                          (_model.course
                                                                      ?.ratingAvg ??
                                                                  widget.detail
                                                                      ?.rating ??
                                                                  0)
                                                              .toStringAsFixed(
                                                                  1),
                                                          '0.0',
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 1,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  'SF Pro Display',
                                                              fontSize: 13.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 4.0)),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 16.0, 20.0, 8.0),
                                          child: Text(
                                            valueOrDefault<String>(
                                              _model.course?.title ??
                                                  widget.detail?.title,
                                              'Name',
                                            ),
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF Pro Display',
                                                  fontSize: 20.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                        if ((_model.course?.subtitle ??
                                                    widget.detail?.subtitle)
                                                ?.trim()
                                                .isNotEmpty ==
                                            true)
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 20.0, 8.0),
                                            child: Text(
                                              (_model.course?.subtitle ??
                                                      widget.detail?.subtitle)!
                                                  .trim(),
                                              textAlign: TextAlign.start,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'SF Pro Display',
                                                    fontSize: 15.0,
                                                    letterSpacing: 0.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    lineHeight: 1.4,
                                                  ),
                                            ),
                                          ),

                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    _model.selectedIndex = 0;
                                                    safeSetState(() {});
                                                  },
                                                  child: _CourseDetailTab(
                                                    icon: Icons.info_outline_rounded,
                                                    label: 'About',
                                                    selected:
                                                        _model.selectedIndex ==
                                                            0,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    _model.selectedIndex = 1;
                                                    safeSetState(() {});
                                                  },
                                                  child: _CourseDetailTab(
                                                    icon: Icons
                                                        .play_lesson_outlined,
                                                    label: 'Lessons',
                                                    selected:
                                                        _model.selectedIndex ==
                                                            1,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    _model.selectedIndex = 2;
                                                    safeSetState(() {});
                                                  },
                                                  child: _CourseDetailTab(
                                                    icon: Icons
                                                        .star_outline_rounded,
                                                    label: 'Reviews',
                                                    selected:
                                                        _model.selectedIndex ==
                                                            2,
                                                  ),
                                                ),
                                              ),
                                            ]
                                                .addToStart(
                                                    SizedBox(width: 20.0))
                                                .addToEnd(
                                                    SizedBox(width: 20.0)),
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            if (_model.selectedIndex == 0) {
                                              return CourseAboutTab(
                                                description:
                                                    _model.courseDescription,
                                                subtitle:
                                                    widget.detail?.subtitle,
                                                level: _model.courseLevel,
                                              );
                                            } else if (_model.selectedIndex ==
                                                1) {
                                              return CourseLessonsTab(
                                                sections: _model.sections,
                                                lessonsCount:
                                                    _model.lessonsCount,
                                                isEnrolled: _model.isEnrolled,
                                              );
                                            } else {
                                              final courseId =
                                                  _model.course?.id ??
                                                      widget.detail?.id ??
                                                      '';
                                              return CourseReviewsTab(
                                                courseId: courseId,
                                                reviews: _model.reviews,
                                                loading: _model.reviewsLoading ||
                                                    _model.detailLoading,
                                                isEnrolled: _model.isEnrolled,
                                                onChanged: () async {
                                                  await _model
                                                      .reloadReviews(courseId);
                                                  if (mounted) {
                                                    safeSetState(() {});
                                                  }
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 17.0, 20.0, 17.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              if (FFAppState().isLogin ==
                                                  true) {
                                                context.pushNamed(
                                                  PaymentMethodPagePurchaseWidget
                                                      .routeName,
                                                  queryParameters: {
                                                    'image': serializeParam(
                                                      widget!.detail?.image,
                                                      ParamType.String,
                                                    ),
                                                    'title': serializeParam(
                                                      widget!.detail?.subject,
                                                      ParamType.String,
                                                    ),
                                                    'subtitle': serializeParam(
                                                      widget!.detail?.subtitle,
                                                      ParamType.String,
                                                    ),
                                                    'price': serializeParam(
                                                      widget!.detail?.price,
                                                      ParamType.String,
                                                    ),
                                                    'instructorName':
                                                        serializeParam(
                                                      widget!.detail
                                                          ?.instructorName,
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Please log in first',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'SF Pro Display',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        fontSize: 17.0,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 2000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                    action: SnackBarAction(
                                                      label: 'Login',
                                                      textColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      onPressed: () async {
                                                        context.pushNamed(
                                                          SignInPageWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'isInner':
                                                                serializeParam(
                                                              true,
                                                              ParamType.bool,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            text:
                                                'Buy ${widget.detail?.price ?? ''}',
                                            options: FFButtonOptions(
                                              width: double.infinity,
                                              height: 56.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            'SF Pro Display',
                                                        color: Colors.white,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        lineHeight: 1.0,
                                                      ),
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
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
    );
  }
}

class _CourseDetailTab extends StatelessWidget {
  const _CourseDetailTab({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = selected ? theme.primary : theme.secondaryText;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.start,
          style: theme.bodyMedium.override(
            fontFamily: 'SF Pro Display',
            fontSize: 15.0,
            letterSpacing: 0.0,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: color,
            lineHeight: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 2.0,
          decoration: BoxDecoration(
            color: selected ? theme.primary : const Color(0x00000000),
          ),
        ),
      ],
    );
  }
}
