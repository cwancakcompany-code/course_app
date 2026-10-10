import 'package:flutter/material.dart';

import '/backend/models/course_entity.dart';
import '/backend/models/course_section_entity.dart';
import '/backend/models/review_entity.dart';
import '/backend/services/catalog_service.dart';
import '/backend/services/enrollment_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'course_detail_page_widget.dart' show CourseDetailPageWidget;

class CourseDetailPageModel extends FlutterFlowModel<CourseDetailPageWidget> {
  int? selectedIndex = 0;

  bool detailLoading = false;
  bool reviewsLoading = false;
  String detailError = '';
  bool isEnrolled = false;
  CourseEntity? course;
  List<CourseSectionEntity> sections = [];
  List<ReviewEntity> reviews = [];

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
        service.loadCourseReviews(courseId),
        EnrollmentService().isEnrolled(courseId),
      ]);
      course = results[0] as CourseEntity?;
      sections = results[1] as List<CourseSectionEntity>;
      reviews = results[2] as List<ReviewEntity>;
      isEnrolled = results[3] as bool;
    } catch (e) {
      detailError = e.toString();
    } finally {
      detailLoading = false;
    }
  }

  Future<void> reloadReviews(String? courseId) async {
    if (courseId == null || courseId.isEmpty) return;
    reviewsLoading = true;
    try {
      reviews = await CatalogService().loadCourseReviews(courseId);
    } finally {
      reviewsLoading = false;
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
