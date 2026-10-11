import '/backend/schema/structs/recommended_for_you_model_struct.dart';
import '/backend/services/enrollment_service.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/center_appbar/center_appbar_widget.dart';
import '/pages/components/completed_component/completed_component_widget.dart';
import '/pages/components/ongoing_component/ongoing_component_widget.dart';
import '/pages/empty_components/no_completed_dialog/no_completed_dialog_widget.dart';
import '/pages/empty_components/no_ongoing_dialog/no_ongoing_dialog_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'my_course_component_model.dart';
export 'my_course_component_model.dart';

class MyCourseComponentWidget extends StatefulWidget {
  const MyCourseComponentWidget({super.key});

  @override
  State<MyCourseComponentWidget> createState() =>
      _MyCourseComponentWidgetState();
}

class _MyCourseComponentWidgetState extends State<MyCourseComponentWidget>
    with TickerProviderStateMixin {
  late MyCourseComponentModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyCourseComponentModel());

    animationsMap.addAll({
      'ongoingComponentOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: null,
      ),
      'completedComponentOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: null,
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEnrollments());
  }

  Future<void> _loadEnrollments() async {
    if (!FFAppState().connected || !FFAppState().isLogin) {
      safeSetState(() {
        _model.isLoading = false;
        _model.loadError = '';
      });
      return;
    }
    safeSetState(() {
      _model.isLoading = true;
      _model.loadError = '';
    });
    try {
      await EnrollmentService().loadMyCourses();
    } catch (e) {
      debugPrint('My Course load error: $e');
      _model.loadError = 'Could not load your courses';
    } finally {
      if (mounted) {
        safeSetState(() => _model.isLoading = false);
      }
    }
  }

  Future<void> _openCourse(String courseId, String title, String image) async {
    if (courseId.isEmpty) return;
    await context.pushNamed(
      CourseDetailPageWidget.routeName,
      queryParameters: {
        'detail': serializeParam(
          RecommendedForYouModelStruct(
            id: courseId,
            title: title,
            image: image,
          ),
          ParamType.DataStruct,
        ),
      }.withoutNulls,
    );
    if (mounted) {
      await _loadEnrollments();
    }
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
      children: [
        wrapWithModel(
          model: _model.centerAppbarModel,
          updateCallback: () => safeSetState(() {}),
          child: CenterAppbarWidget(
            title: 'My Course',
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _model.selectedTabIndex = 0;
                    _model.updatePage(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Ongoing',
                          textAlign: TextAlign.start,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.5,
                                  ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.0,
                          decoration: BoxDecoration(
                            color: _model.selectedTabIndex == 0
                                ? FlutterFlowTheme.of(context).primary
                                : Color(0x00000000),
                          ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _model.selectedTabIndex = 1;
                    _model.updatePage(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Completed',
                          textAlign: TextAlign.start,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.5,
                                  ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2.0,
                          decoration: BoxDecoration(
                            color: _model.selectedTabIndex == 1
                                ? FlutterFlowTheme.of(context).primary
                                : Color(0x00000000),
                          ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                ),
              ),
            ].addToStart(SizedBox(width: 20.0)).addToEnd(SizedBox(width: 20.0)),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (!FFAppState().connected) {
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
              if (_model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_model.loadError.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _model.loadError,
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _loadEnrollments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (_model.selectedTabIndex == 0) {
                if (FFAppState().isLogin != true ||
                    FFAppState().OngoingList.isEmpty) {
                  return wrapWithModel(
                    model: _model.noOngoingDialogModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NoOngoingDialogWidget(),
                  );
                }
                final ongoing = FFAppState().OngoingList.toList();
                return RefreshIndicator(
                  onRefresh: _loadEnrollments,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    itemCount: ongoing.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, ongoingIndex) {
                      final ongoingItem = ongoing[ongoingIndex];
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 0, 20, 0),
                        child: wrapWithModel(
                          model: _model.ongoingComponentModels.getModel(
                            ongoingItem.id.isNotEmpty
                                ? ongoingItem.id
                                : ongoingItem.title,
                            ongoingIndex,
                          ),
                          updateCallback: () => safeSetState(() {}),
                          child: OngoingComponentWidget(
                            key: Key('ongoing_${ongoingItem.id}'),
                            image: ongoingItem.image,
                            name: ongoingItem.title,
                            time: ongoingItem.time,
                            totalCourse: ongoingItem.totalCourse,
                            running: ongoingItem.running,
                            onTap: () => _openCourse(
                              ongoingItem.id,
                              ongoingItem.title,
                              ongoingItem.image,
                            ),
                          ),
                        ).animateOnPageLoad(
                          animationsMap[
                              'ongoingComponentOnPageLoadAnimation']!,
                          effects: [
                            MoveEffect(
                              curve: Curves.easeInOut,
                              delay: valueOrDefault<double>(
                                ongoingIndex * 111,
                                0.0,
                              ).ms,
                              duration: 300.0.ms,
                              begin: const Offset(20.0, 0.0),
                              end: const Offset(0.0, 0.0),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              if (FFAppState().isLogin != true ||
                  FFAppState().CompletedList.isEmpty) {
                return wrapWithModel(
                  model: _model.noCompletedDialogModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NoCompletedDialogWidget(),
                );
              }
              final complete = FFAppState().CompletedList.toList();
              return RefreshIndicator(
                onRefresh: _loadEnrollments,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  itemCount: complete.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, completeIndex) {
                    final completeItem = complete[completeIndex];
                    return Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: wrapWithModel(
                        model: _model.completedComponentModels.getModel(
                          completeItem.id.isNotEmpty
                              ? completeItem.id
                              : completeItem.title,
                          completeIndex,
                        ),
                        updateCallback: () => safeSetState(() {}),
                        child: CompletedComponentWidget(
                          key: Key('completed_${completeItem.id}'),
                          image: completeItem.image,
                          name: completeItem.title,
                          time: completeItem.time,
                          onTap: () => _openCourse(
                            completeItem.id,
                            completeItem.title,
                            completeItem.image,
                          ),
                        ),
                      ).animateOnPageLoad(
                        animationsMap[
                            'completedComponentOnPageLoadAnimation']!,
                        effects: [
                          MoveEffect(
                            curve: Curves.easeInOut,
                            delay: valueOrDefault<double>(
                              completeIndex * 111,
                              0.0,
                            ).ms,
                            duration: 300.0.ms,
                            begin: const Offset(20.0, 0.0),
                            end: const Offset(0.0, 0.0),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
