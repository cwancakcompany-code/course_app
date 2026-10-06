// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StudentModelStruct extends BaseStruct {
  StudentModelStruct({
    String? image,
    String? title,
  })  : _image = image,
        _title = title;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  static StudentModelStruct fromMap(Map<String, dynamic> data) =>
      StudentModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
      );

  static StudentModelStruct? maybeFromMap(dynamic data) => data is Map
      ? StudentModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
      }.withoutNulls;

  static StudentModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      StudentModelStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'StudentModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StudentModelStruct &&
        image == other.image &&
        title == other.title;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title]);
}

StudentModelStruct createStudentModelStruct({
  String? image,
  String? title,
}) =>
    StudentModelStruct(
      image: image,
      title: title,
    );
