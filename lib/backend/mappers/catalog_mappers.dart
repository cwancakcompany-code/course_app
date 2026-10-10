import '/backend/media/media_url_resolver.dart';
import '/backend/models/category_entity.dart';
import '/backend/models/course_entity.dart';
import '/backend/models/instructor_entity.dart';
import '/backend/schema/structs/index.dart';
import '/backend/utils/price_formatter.dart';

/// Maps domain entities to FlutterFlow UI structs.
class CatalogMappers {
  CatalogMappers._();

  static const _media = MediaUrlResolver();

  static CategoryModelStruct toCategoryStruct(CategoryEntity entity) {
    return CategoryModelStruct(
      // Only Lucide / icon token from DB — UI keeps default background.
      image: (entity.iconUrl ?? '').trim(),
      name: entity.name,
    );
  }

  static InstructorModelStruct toInstructorStruct(InstructorEntity entity) {
    return InstructorModelStruct(
      image: _media.resolveImage(entity.avatarUrl),
      name: entity.displayName,
      students: entity.studentsCount.toString(),
      courses: entity.coursesCount.toString(),
      reviews: entity.reviewsCount.toString(),
      subject: entity.title ?? '',
    );
  }

  static RecommendedForYouModelStruct toCourseStruct(CourseEntity entity) {
    final thumb = _media.resolveImage(entity.thumbnailUrl);
    final bunnyThumb = thumb.isEmpty
        ? _media.bunnyThumbnail(entity.previewVideoUrl)
        : '';

    return RecommendedForYouModelStruct(
      id: entity.id,
      image: thumb.isNotEmpty ? thumb : bunnyThumb,
      title: entity.title,
      subtitle: entity.subtitle?.isNotEmpty == true
          ? entity.subtitle
          : (entity.categoryName ?? ''),
      instructorName: entity.instructorName ?? '',
      profileImage: _media.resolveImage(entity.instructorAvatarUrl),
      price: PriceFormatter.format(entity.price, currency: entity.currency),
      rating: entity.ratingAvg,
      subject: entity.instructorTitle ?? entity.categoryName ?? '',
    );
  }

}
