import '/backend/schema/structs/recommended_for_you_model_struct.dart';

/// Filters catalog courses by a free-text query (title, subtitle, instructor, subject).
class CourseSearch {
  const CourseSearch._();

  static List<RecommendedForYouModelStruct> filter(
    Iterable<RecommendedForYouModelStruct> courses,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    return courses.where((course) {
      final haystack = [
        course.title,
        course.subtitle,
        course.instructorName,
        course.subject,
      ].join(' ').toLowerCase();
      return tokens.every(haystack.contains);
    }).toList(growable: false);
  }

  /// Deduped union of catalog lists for searching.
  static List<RecommendedForYouModelStruct> catalogPool({
    required List<RecommendedForYouModelStruct> recommended,
    required List<RecommendedForYouModelStruct> popular,
    List<RecommendedForYouModelStruct> extra = const [],
  }) {
    final byKey = <String, RecommendedForYouModelStruct>{};
    for (final course in [...recommended, ...popular, ...extra]) {
      final key = course.id.isNotEmpty
          ? course.id
          : '${course.title}|${course.subtitle}|${course.price}';
      byKey.putIfAbsent(key, () => course);
    }
    return byKey.values.toList(growable: false);
  }
}
