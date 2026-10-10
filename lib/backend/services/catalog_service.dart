import 'package:flutter/foundation.dart';

import '/backend/models/category_entity.dart';
import '/backend/models/course_entity.dart';
import '/backend/models/course_section_entity.dart';
import '/backend/models/instructor_entity.dart';
import '/backend/models/review_entity.dart';
import '/backend/repositories/category_repository.dart';
import '/backend/repositories/course_repository.dart';
import '/backend/repositories/instructor_repository.dart';
import '/backend/repositories/lesson_repository.dart';
import '/backend/repositories/review_repository.dart';

class HomeCatalogSnapshot {
  const HomeCatalogSnapshot({
    required this.categories,
    required this.instructors,
    required this.recommended,
    required this.popular,
    required this.recent,
    required this.coursesById,
  });

  final List<CategoryEntity> categories;
  final List<InstructorEntity> instructors;
  final List<CourseEntity> recommended;
  final List<CourseEntity> popular;
  final List<CourseEntity> recent;
  final Map<String, CourseEntity> coursesById;
}

/// Facade for home/catalog reads. Parallel queries, no N+1 for list screens.
class CatalogService {
  CatalogService({
    CategoryRepository? categoryRepository,
    CourseRepository? courseRepository,
    InstructorRepository? instructorRepository,
    LessonRepository? lessonRepository,
    ReviewRepository? reviewRepository,
  })  : _categories = categoryRepository ?? SupabaseCategoryRepository(),
        _courses = courseRepository ?? SupabaseCourseRepository(),
        _instructors = instructorRepository ?? SupabaseInstructorRepository(),
        _lessons = lessonRepository ?? SupabaseLessonRepository(),
        _reviews = reviewRepository ?? SupabaseReviewRepository();

  final CategoryRepository _categories;
  final CourseRepository _courses;
  final InstructorRepository _instructors;
  final LessonRepository _lessons;
  final ReviewRepository _reviews;

  HomeCatalogSnapshot? _cache;
  DateTime? _cacheAt;
  static const _ttl = Duration(seconds: 30);

  Future<HomeCatalogSnapshot> loadHomeCatalog({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cacheAt != null &&
        now.difference(_cacheAt!) < _ttl) {
      return _cache!;
    }

    final results = await Future.wait([
      _safeList(_categories.fetchActive()),
      _safeList(_instructors.fetchActive()),
      _safeList(_courses.fetchRecommended()),
      _safeList(_courses.fetchPopular()),
      _safeList(_courses.fetchPublished(limit: 20)),
    ]);

    final categories = results[0] as List<CategoryEntity>;
    final instructors = results[1] as List<InstructorEntity>;
    final recommended = results[2] as List<CourseEntity>;
    final popular = results[3] as List<CourseEntity>;
    final recent = results[4] as List<CourseEntity>;

    final coursesById = <String, CourseEntity>{};
    for (final course in [...recommended, ...popular, ...recent]) {
      coursesById[course.id] = course;
    }

    final snapshot = HomeCatalogSnapshot(
      categories: categories,
      instructors: instructors,
      recommended: recommended,
      popular: popular,
      recent: recent,
      coursesById: coursesById,
    );
    _cache = snapshot;
    _cacheAt = now;
    return snapshot;
  }

  Future<List<CourseSectionEntity>> loadCourseCurriculum(String courseId) {
    return _lessons.fetchSectionsWithLessons(courseId);
  }

  Future<CourseEntity?> loadCourseById(String courseId) {
    return _courses.fetchById(courseId);
  }

  Future<List<CourseEntity>> loadCoursesByCategory(String categoryId) {
    return _courses.fetchByCategory(categoryId);
  }

  Future<List<CourseEntity>> loadCoursesByInstructor(String instructorId) {
    return _courses.fetchByInstructor(instructorId);
  }

  Future<List<ReviewEntity>> loadCourseReviews(String courseId) {
    return _safeList(_reviews.fetchByCourse(courseId));
  }

  Future<ReviewEntity> submitCourseReview({
    required String courseId,
    required String userId,
    required double rating,
    String? comment,
  }) {
    return _reviews.upsertReview(
      courseId: courseId,
      userId: userId,
      rating: rating,
      comment: comment,
    );
  }

  void clearCache() {
    _cache = null;
    _cacheAt = null;
  }

  Future<List<T>> _safeList<T>(Future<List<T>> future) async {
    try {
      return await future;
    } catch (e, st) {
      debugPrint('Catalog query failed ($T): $e');
      debugPrint('$st');
      return <T>[];
    }
  }
}
