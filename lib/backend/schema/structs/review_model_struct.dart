// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReviewModelStruct extends BaseStruct {
  ReviewModelStruct({
    String? image,
    String? name,
    String? createAt,
    String? subTitle,
    double? review,
  })  : _image = image,
        _name = name,
        _createAt = createAt,
        _subTitle = subTitle,
        _review = review;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "createAt" field.
  String? _createAt;
  String get createAt => _createAt ?? '';
  set createAt(String? val) => _createAt = val;

  bool hasCreateAt() => _createAt != null;

  // "subTitle" field.
  String? _subTitle;
  String get subTitle => _subTitle ?? '';
  set subTitle(String? val) => _subTitle = val;

  bool hasSubTitle() => _subTitle != null;

  // "review" field.
  double? _review;
  double get review => _review ?? 0.0;
  set review(double? val) => _review = val;

  void incrementReview(double amount) => review = review + amount;

  bool hasReview() => _review != null;

  static ReviewModelStruct fromMap(Map<String, dynamic> data) =>
      ReviewModelStruct(
        image: data['image'] as String?,
        name: data['name'] as String?,
        createAt: data['createAt'] as String?,
        subTitle: data['subTitle'] as String?,
        review: castToType<double>(data['review']),
      );

  static ReviewModelStruct? maybeFromMap(dynamic data) => data is Map
      ? ReviewModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'name': _name,
        'createAt': _createAt,
        'subTitle': _subTitle,
        'review': _review,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'createAt': serializeParam(
          _createAt,
          ParamType.String,
        ),
        'subTitle': serializeParam(
          _subTitle,
          ParamType.String,
        ),
        'review': serializeParam(
          _review,
          ParamType.double,
        ),
      }.withoutNulls;

  static ReviewModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      ReviewModelStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        createAt: deserializeParam(
          data['createAt'],
          ParamType.String,
          false,
        ),
        subTitle: deserializeParam(
          data['subTitle'],
          ParamType.String,
          false,
        ),
        review: deserializeParam(
          data['review'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'ReviewModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ReviewModelStruct &&
        image == other.image &&
        name == other.name &&
        createAt == other.createAt &&
        subTitle == other.subTitle &&
        review == other.review;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([image, name, createAt, subTitle, review]);
}

ReviewModelStruct createReviewModelStruct({
  String? image,
  String? name,
  String? createAt,
  String? subTitle,
  double? review,
}) =>
    ReviewModelStruct(
      image: image,
      name: name,
      createAt: createAt,
      subTitle: subTitle,
      review: review,
    );
