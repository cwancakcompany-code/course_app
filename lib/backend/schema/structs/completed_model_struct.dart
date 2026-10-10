// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CompletedModelStruct extends BaseStruct {
  CompletedModelStruct({
    String? id,
    String? image,
    String? title,
    String? time,
  })  : _id = id,
        _image = image,
        _title = title,
        _time = time;

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

  String? _time;
  String get time => _time ?? '';
  set time(String? val) => _time = val;
  bool hasTime() => _time != null;

  static CompletedModelStruct fromMap(Map<String, dynamic> data) =>
      CompletedModelStruct(
        id: data['id'] as String?,
        image: data['image'] as String?,
        title: data['title'] as String?,
        time: data['time'] as String?,
      );

  static CompletedModelStruct? maybeFromMap(dynamic data) => data is Map
      ? CompletedModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'image': _image,
        'title': _title,
        'time': _time,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
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
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
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
        id == other.id &&
        image == other.image &&
        title == other.title &&
        time == other.time;
  }

  @override
  int get hashCode => const ListEquality().hash([id, image, title, time]);
}

CompletedModelStruct createCompletedModelStruct({
  String? id,
  String? image,
  String? title,
  String? time,
}) =>
    CompletedModelStruct(
      id: id,
      image: image,
      title: title,
      time: time,
    );
