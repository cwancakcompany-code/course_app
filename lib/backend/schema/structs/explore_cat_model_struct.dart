// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ExploreCatModelStruct extends BaseStruct {
  ExploreCatModelStruct({
    String? image,
    String? name,
    Color? color,
  })  : _image = image,
        _name = name,
        _color = color;

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

  // "color" field.
  Color? _color;
  Color? get color => _color;
  set color(Color? val) => _color = val;

  bool hasColor() => _color != null;

  static ExploreCatModelStruct fromMap(Map<String, dynamic> data) =>
      ExploreCatModelStruct(
        image: data['image'] as String?,
        name: data['name'] as String?,
        color: getSchemaColor(data['color']),
      );

  static ExploreCatModelStruct? maybeFromMap(dynamic data) => data is Map
      ? ExploreCatModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'name': _name,
        'color': _color,
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
        'color': serializeParam(
          _color,
          ParamType.Color,
        ),
      }.withoutNulls;

  static ExploreCatModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      ExploreCatModelStruct(
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
        color: deserializeParam(
          data['color'],
          ParamType.Color,
          false,
        ),
      );

  @override
  String toString() => 'ExploreCatModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ExploreCatModelStruct &&
        image == other.image &&
        name == other.name &&
        color == other.color;
  }

  @override
  int get hashCode => const ListEquality().hash([image, name, color]);
}

ExploreCatModelStruct createExploreCatModelStruct({
  String? image,
  String? name,
  Color? color,
}) =>
    ExploreCatModelStruct(
      image: image,
      name: name,
      color: color,
    );
