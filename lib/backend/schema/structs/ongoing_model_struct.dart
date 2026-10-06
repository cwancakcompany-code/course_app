// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OngoingModelStruct extends BaseStruct {
  OngoingModelStruct({
    String? image,
    String? title,

    ///
    ///
    String? time,
    int? running,
    int? totalCourse,
  })  : _image = image,
        _title = title,
        _time = time,
        _running = running,
        _totalCourse = totalCourse;

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

  // "running" field.
  int? _running;
  int get running => _running ?? 0;
  set running(int? val) => _running = val;

  void incrementRunning(int amount) => running = running + amount;

  bool hasRunning() => _running != null;

  // "totalCourse" field.
  int? _totalCourse;
  int get totalCourse => _totalCourse ?? 0;
  set totalCourse(int? val) => _totalCourse = val;

  void incrementTotalCourse(int amount) => totalCourse = totalCourse + amount;

  bool hasTotalCourse() => _totalCourse != null;

  static OngoingModelStruct fromMap(Map<String, dynamic> data) =>
      OngoingModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
        time: data['time'] as String?,
        running: castToType<int>(data['running']),
        totalCourse: castToType<int>(data['totalCourse']),
      );

  static OngoingModelStruct? maybeFromMap(dynamic data) => data is Map
      ? OngoingModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
        'time': _time,
        'running': _running,
        'totalCourse': _totalCourse,
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
        'running': serializeParam(
          _running,
          ParamType.int,
        ),
        'totalCourse': serializeParam(
          _totalCourse,
          ParamType.int,
        ),
      }.withoutNulls;

  static OngoingModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      OngoingModelStruct(
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
        running: deserializeParam(
          data['running'],
          ParamType.int,
          false,
        ),
        totalCourse: deserializeParam(
          data['totalCourse'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'OngoingModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OngoingModelStruct &&
        image == other.image &&
        title == other.title &&
        time == other.time &&
        running == other.running &&
        totalCourse == other.totalCourse;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([image, title, time, running, totalCourse]);
}

OngoingModelStruct createOngoingModelStruct({
  String? image,
  String? title,
  String? time,
  int? running,
  int? totalCourse,
}) =>
    OngoingModelStruct(
      image: image,
      title: title,
      time: time,
      running: running,
      totalCourse: totalCourse,
    );
