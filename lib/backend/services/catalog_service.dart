import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/media/media_url_resolver.dart';
import '/backend/models/category_entity.dart';
import '/backend/models/course_entity.dart';
import '/backend/models/course_section_entity.dart';
import '/backend/models/instructor_entity.dart';
import '/backend/models/instructor_review_entity.dart';
import '/backend/models/review_entity.dart';
import '/backend/repositories/category_repository.dart';
import '/backend/repositories/course_repository.dart';
import '/backend/repositories/instructor_repository.dart';
import '/backend/repositories/instructor_review_repository.dart';
import '/backend/repositories/lesson_repository.dart';
import '/backend/repositories/review_repository.dart';
import '/backend/schema/structs/student_model_struct.dart';
import '/backend/supabase/supabase_bootstrap.dart';

class HomeCatalogSnapshot {
  const HomeCatalogSnapshot({
    required this.categories,
    required this.instructors,
    required this.recommended,
    required this.popular,
    required this.recent,
    required this.coursesById,
    required this.allCourses,
  });

  final List<CategoryEntity> categories;
  final List<InstructorEntity> instructors;
  final List<CourseEntity> recommended;
  final List<CourseEntity> popular;
  final List<CourseEntity> recent;
  final Map<String, CourseEntity> coursesById;
  final List<CourseEntity> allCourses;
}

/// Facade for home/catalog reads. Parallel queries, no N+1 for list screens.
class CatalogService {
  CatalogService({
    CategoryRepository? categoryRepository,
    CourseRepository? courseRepository,
    InstructorRepository? instructorRepository,
    LessonRepository? lessonRepository,
    ReviewRepository? reviewRepository,
    InstructorReviewRepository? instructorReviewRepository,
  })  : _categories = categoryRepository ?? SupabaseCategoryRepository(),
        _courses = courseRepository ?? SupabaseCourseRepository(),
        _instructors = instructorRepository ?? SupabaseInstructorRepository(),
        _lessons = lessonRepository ?? SupabaseLessonRepository(),
        _reviews = reviewRepository ?? SupabaseReviewRepository(),
        _instructorReviews =
            instructorReviewRepository ?? SupabaseInstructorReviewRepository();

  final CategoryRepository _categories;
  final CourseRepository _courses;
  final InstructorRepository _instructors;
  final LessonRepository _lessons;
  final ReviewRepository _reviews;
  final InstructorReviewRepository _instructorReviews;

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
      _safeList(_courses.fetchPublished(limit: 60)),
    ]);

    final categories = results[0] as List<CategoryEntity>;
    final instructors = results[1] as List<InstructorEntity>;
    final rawRecommended = results[2] as List<CourseEntity>;
    final rawPopular = results[3] as List<CourseEntity>;
    final rawRecent = results[4] as List<CourseEntity>;

    final instructorMap = {for (final ins in instructors) ins.id: ins};

    CourseEntity hydrate(CourseEntity course) {
      if ((course.instructorName != null && course.instructorName!.isNotEmpty) &&
          (course.instructorAvatarUrl != null && course.instructorAvatarUrl!.isNotEmpty)) {
        return course;
      }
      final matched = (course.instructorId != null ? instructorMap[course.instructorId] : null) ??
          (instructors.isNotEmpty ? instructors.first : null);
      if (matched == null) return course;
      return course.copyWith(
        instructorName: (course.instructorName != null && course.instructorName!.isNotEmpty)
            ? course.instructorName
            : matched.displayName,
        instructorAvatarUrl: (course.instructorAvatarUrl != null && course.instructorAvatarUrl!.isNotEmpty)
            ? course.instructorAvatarUrl
            : matched.avatarUrl,
        instructorTitle: (course.instructorTitle != null && course.instructorTitle!.isNotEmpty)
            ? course.instructorTitle
            : matched.title,
      );
    }

    final recommended = rawRecommended.map(hydrate).toList(growable: false);
    final popular = rawPopular.map(hydrate).toList(growable: false);
    final recent = rawRecent.map(hydrate).toList(growable: false);

    final coursesById = <String, CourseEntity>{};
    for (final course in [...recent, ...recommended, ...popular]) {
      coursesById[course.id] = course;
    }
    final allCourses = coursesById.values.toList(growable: false);

    final snapshot = HomeCatalogSnapshot(
      categories: categories,
      instructors: instructors,
      recommended: recommended,
      popular: popular,
      recent: recent,
      coursesById: coursesById,
      allCourses: allCourses,
    );
    _cache = snapshot;
    _cacheAt = now;
    return snapshot;
  }

  Future<List<CourseEntity>> loadAllCourses({bool forceRefresh = false}) async {
    final snapshot = await loadHomeCatalog(forceRefresh: forceRefresh);
    return snapshot.allCourses;
  }

  Future<List<CourseSectionEntity>> loadCourseCurriculum(String courseId) {
    return _lessons.fetchSectionsWithLessons(courseId);
  }

  Future<CourseEntity?> loadCourseById(String courseId) async {
    final course = await _courses.fetchById(courseId);
    if (course == null) return null;
    if (course.instructorName != null && course.instructorName!.isNotEmpty) {
      return course;
    }
    if (course.instructorId != null) {
      final ins = await _instructors.fetchById(course.instructorId!);
      if (ins != null) {
        return course.copyWith(
          instructorName: ins.displayName,
          instructorAvatarUrl: ins.avatarUrl,
          instructorTitle: ins.title,
        );
      }
    }
    return course;
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

  Future<List<InstructorReviewEntity>> loadInstructorReviews(
    String instructorId,
  ) {
    return _safeList(_instructorReviews.fetchByInstructor(instructorId));
  }

  Future<bool> canReviewInstructor(String instructorId) {
    return _instructorReviews.canReview(instructorId);
  }

  Future<InstructorReviewEntity> submitInstructorReview({
    required String instructorId,
    required String userId,
    required double rating,
    String? comment,
  }) {
    return _instructorReviews.upsertReview(
      instructorId: instructorId,
      userId: userId,
      rating: rating,
      comment: comment,
    );
  }

  Future<List<StudentModelStruct>> loadInstructorStudents({
    String? instructorId,
    String? instructorName,
  }) async {
    try {
      final client = SupabaseBootstrap.client;
      String? resolvedId = instructorId;

      if (resolvedId == null || resolvedId.isEmpty) {
        if (instructorName != null && instructorName.isNotEmpty) {
          final insRow = await client
              .from('instructors')
              .select('id')
              .ilike('display_name', instructorName)
              .maybeSingle();
          resolvedId = insRow?['id'] as String?;
        }
      }

      if (resolvedId == null || resolvedId.isEmpty) {
        final first = await client
            .from('instructors')
            .select('id')
            .limit(1)
            .maybeSingle();
        resolvedId = first?['id'] as String?;
      }

      if (resolvedId == null || resolvedId.isEmpty) {
        return <StudentModelStruct>[];
      }

      final secretKey = dotenv.env['SUPABASE_SECRET_KEY'] ?? '';
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ?? '';

      final queryClient = (secretKey.isNotEmpty && supabaseUrl.isNotEmpty)
          ? SupabaseClient(supabaseUrl, secretKey)
          : client;

      final rows = await queryClient
          .from('enrollments')
          .select('user_id, courses!inner(instructor_id), profiles(id, first_name, last_name, avatar_url, user_name)')
          .eq('courses.instructor_id', resolvedId);

      const media = MediaUrlResolver();
      final seenIds = <String>{};
      final list = <StudentModelStruct>[];

      for (final raw in (rows as List)) {
        final row = Map<String, dynamic>.from(raw as Map);
        final profile = row['profiles'] as Map<String, dynamic>?;
        if (profile == null) continue;
        final studentId = profile['id'] as String? ?? '';
        if (studentId.isNotEmpty && seenIds.contains(studentId)) continue;
        if (studentId.isNotEmpty) seenIds.add(studentId);

        final first = (profile['first_name'] as String?)?.trim() ?? '';
        final last = (profile['last_name'] as String?)?.trim() ?? '';
        final username = (profile['user_name'] as String?)?.trim() ?? '';
        final name = (first.isNotEmpty || last.isNotEmpty)
            ? '$first $last'.trim()
            : (username.isNotEmpty ? username : 'Student');

        final avatarUrl = media.resolveImage(profile['avatar_url'] as String?);

        list.add(
          StudentModelStruct(
            image: avatarUrl,
            title: name,
          ),
        );
      }

      return list;
    } catch (e, st) {
      debugPrint('loadInstructorStudents failed: $e\n$st');
      return <StudentModelStruct>[];
    }
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
