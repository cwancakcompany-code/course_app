// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CompletedModelStruct extends BaseStruct {
  CompletedModelStruct({
    String? image,
    String? title,

    ///
    ///
    String? time,
  })  : _image = image,
        _title = title,
        _time = time;

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

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  set time(String? val) => _time = val;

  bool hasTime() => _time != null;

  static CompletedModelStruct fromMap(Map<String, dynamic> data) =>
      CompletedModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
        time: data['time'] as String?,
      );

  static CompletedModelStruct? maybeFromMap(dynamic data) => data is Map
      ? CompletedModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
        'time': _time,
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
        'time': serializeParam(
          _time,
          ParamType.String,
        ),
      }.withoutNulls;

  static CompletedModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      CompletedModelStruct(
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
        time: deserializeParam(
          data['time'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CompletedModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CompletedModelStruct &&
        image == other.image &&
        title == other.title &&
        time == other.time;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title, time]);
}

CompletedModelStruct createCompletedModelStruct({
  String? image,
  String? title,
  String? time,
}) =>
    CompletedModelStruct(
      image: image,
      title: title,
      time: time,
    );
