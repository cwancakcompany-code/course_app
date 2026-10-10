import 'package:flutter/material.dart';

import '/backend/models/course_entity.dart';
import '/backend/models/course_section_entity.dart';
import '/backend/services/catalog_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/review_component/review_component_widget.dart';
import 'course_detail_page_widget.dart' show CourseDetailPageWidget;

class CourseDetailPageModel extends FlutterFlowModel<CourseDetailPageWidget> {
  int? selectedIndex = 0;

  bool detailLoading = false;
  String detailError = '';
  CourseEntity? course;
  List<CourseSectionEntity> sections = [];

  late FlutterFlowDynamicModels<ReviewComponentModel> reviewComponentModels;

  String get courseDescription =>
      course?.description?.trim().isNotEmpty == true
          ? course!.description!.trim()
          : (course?.subtitle?.trim() ?? '');

  String? get courseLevel => course?.level;

  int get lessonsCount =>
      course?.lessonsCount ??
      sections.fold<int>(0, (sum, s) => sum + s.lessons.length);

  String get previewVideoGuid => course?.previewVideoUrl?.trim() ?? '';

  Future<void> loadCourseDetail(String? courseId) async {
    if (courseId == null || courseId.isEmpty) return;
    detailLoading = true;
    detailError = '';
    try {
      final service = CatalogService();
      final results = await Future.wait([
        service.loadCourseById(courseId),
        service.loadCourseCurriculum(courseId),
      ]);
      course = results[0] as CourseEntity?;
      sections = results[1] as List<CourseSectionEntity>;
    } catch (e) {
      detailError = e.toString();
    } finally {
      detailLoading = false;
    }
  }

  @override
  void initState(BuildContext context) {
    reviewComponentModels =
        FlutterFlowDynamicModels(() => ReviewComponentModel());
  }

  @override
  void dispose() {
    reviewComponentModels.dispose();
  }
}
