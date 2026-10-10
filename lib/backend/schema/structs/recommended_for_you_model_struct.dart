// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RecommendedForYouModelStruct extends BaseStruct {
  RecommendedForYouModelStruct({
    String? id,
    String? image,
    String? title,
    String? subtitle,
    String? instructorName,
    String? profileImage,
    String? price,
    double? rating,
    String? subject,
  })  : _id = id,
        _image = image,
        _title = title,
        _subtitle = subtitle,
        _instructorName = instructorName,
        _profileImage = profileImage,
        _price = price,
        _rating = rating,
        _subject = subject;

  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;
  bool hasImage() => _image != null;

  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  String? _subtitle;
  String get subtitle => _subtitle ?? '';
  set subtitle(String? val) => _subtitle = val;
  bool hasSubtitle() => _subtitle != null;

  String? _instructorName;
  String get instructorName => _instructorName ?? '';
  set instructorName(String? val) => _instructorName = val;
  bool hasInstructorName() => _instructorName != null;

  String? _profileImage;
  String get profileImage => _profileImage ?? '';
  set profileImage(String? val) => _profileImage = val;
  bool hasProfileImage() => _profileImage != null;

  String? _price;
  String get price => _price ?? '';
  set price(String? val) => _price = val;
  bool hasPrice() => _price != null;

  double? _rating;
  double get rating => _rating ?? 0.0;
  set rating(double? val) => _rating = val;
  void incrementRating(double amount) => rating = rating + amount;
  bool hasRating() => _rating != null;

  String? _subject;
  String get subject => _subject ?? '';
  set subject(String? val) => _subject = val;
  bool hasSubject() => _subject != null;

  static RecommendedForYouModelStruct fromMap(Map<String, dynamic> data) =>
      RecommendedForYouModelStruct(
        id: data['id'] as String?,
        image: data['image'] as String?,
        title: data['title'] as String?,
        subtitle: data['subtitle'] as String?,
        instructorName: data['instructorName'] as String?,
        profileImage: data['profileImage'] as String?,
        price: data['price'] as String?,
        rating: castToType<double>(data['rating']),
        subject: data['subject'] as String?,
      );

  static RecommendedForYouModelStruct? maybeFromMap(dynamic data) => data is Map
      ? RecommendedForYouModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'image': _image,
        'title': _title,
        'subtitle': _subtitle,
        'instructorName': _instructorName,
        'profileImage': _profileImage,
        'price': _price,
        'rating': _rating,
        'subject': _subject,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'image': serializeParam(_image, ParamType.String),
        'title': serializeParam(_title, ParamType.String),
        'subtitle': serializeParam(_subtitle, ParamType.String),
        'instructorName': serializeParam(_instructorName, ParamType.String),
        'profileImage': serializeParam(_profileImage, ParamType.String),
        'price': serializeParam(_price, ParamType.String),
        'rating': serializeParam(_rating, ParamType.double),
        'subject': serializeParam(_subject, ParamType.String),
      }.withoutNulls;

  static RecommendedForYouModelStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      RecommendedForYouModelStruct(
        id: deserializeParam(data['id'], ParamType.String, false),
        image: deserializeParam(data['image'], ParamType.String, false),
        title: deserializeParam(data['title'], ParamType.String, false),
        subtitle: deserializeParam(data['subtitle'], ParamType.String, false),
        instructorName:
            deserializeParam(data['instructorName'], ParamType.String, false),
        profileImage:
            deserializeParam(data['profileImage'], ParamType.String, false),
        price: deserializeParam(data['price'], ParamType.String, false),
        rating: deserializeParam(data['rating'], ParamType.double, false),
        subject: deserializeParam(data['subject'], ParamType.String, false),
      );

  @override
  String toString() => 'RecommendedForYouModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is RecommendedForYouModelStruct &&
        id == other.id &&
        image == other.image &&
        title == other.title &&
        subtitle == other.subtitle &&
        instructorName == other.instructorName &&
        profileImage == other.profileImage &&
        price == other.price &&
        rating == other.rating &&
        subject == other.subject;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        image,
        title,
        subtitle,
        instructorName,
        profileImage,
        price,
        rating,
        subject
      ]);
}

RecommendedForYouModelStruct createRecommendedForYouModelStruct({
  String? id,
  String? image,
  String? title,
  String? subtitle,
  String? instructorName,
  String? profileImage,
  String? price,
  double? rating,
  String? subject,
}) =>
    RecommendedForYouModelStruct(
      id: id,
      image: image,
      title: title,
      subtitle: subtitle,
      instructorName: instructorName,
      profileImage: profileImage,
      price: price,
      rating: rating,
      subject: subject,
    );
