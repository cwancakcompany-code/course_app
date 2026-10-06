// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InstructorModelStruct extends BaseStruct {
  InstructorModelStruct({
    String? image,
    String? name,
    String? students,
    String? courses,
    String? reviews,
    String? subject,
  })  : _image = image,
        _name = name,
        _students = students,
        _courses = courses,
        _reviews = reviews,
        _subject = subject;

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

  // "students" field.
  String? _students;
  String get students => _students ?? '';
  set students(String? val) => _students = val;

  bool hasStudents() => _students != null;

  // "courses" field.
  String? _courses;
  String get courses => _courses ?? '';
  set courses(String? val) => _courses = val;

  bool hasCourses() => _courses != null;

  // "reviews" field.
  String? _reviews;
  String get reviews => _reviews ?? '';
  set reviews(String? val) => _reviews = val;

  bool hasReviews() => _reviews != null;

  // "subject" field.
  String? _subject;
  String get subject => _subject ?? '';
  set subject(String? val) => _subject = val;

  bool hasSubject() => _subject != null;

  static InstructorModelStruct fromMap(Map<String, dynamic> data) =>
      InstructorModelStruct(
        image: data['image'] as String?,
        name: data['name'] as String?,
        students: data['students'] as String?,
        courses: data['courses'] as String?,
        reviews: data['reviews'] as String?,
        subject: data['subject'] as String?,
      );

  static InstructorModelStruct? maybeFromMap(dynamic data) => data is Map
      ? InstructorModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'name': _name,
        'students': _students,
        'courses': _courses,
        'reviews': _reviews,
        'subject': _subject,
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
        'students': serializeParam(
          _students,
          ParamType.String,
        ),
        'courses': serializeParam(
          _courses,
          ParamType.String,
        ),
        'reviews': serializeParam(
          _reviews,
          ParamType.String,
        ),
        'subject': serializeParam(
          _subject,
          ParamType.String,
        ),
      }.withoutNulls;

  static InstructorModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      InstructorModelStruct(
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
        students: deserializeParam(
          data['students'],
          ParamType.String,
          false,
        ),
        courses: deserializeParam(
          data['courses'],
          ParamType.String,
          false,
        ),
        reviews: deserializeParam(
          data['reviews'],
          ParamType.String,
          false,
        ),
        subject: deserializeParam(
          data['subject'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'InstructorModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is InstructorModelStruct &&
        image == other.image &&
        name == other.name &&
        students == other.students &&
        courses == other.courses &&
        reviews == other.reviews &&
        subject == other.subject;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([image, name, students, courses, reviews, subject]);
}

InstructorModelStruct createInstructorModelStruct({
  String? image,
  String? name,
  String? students,
  String? courses,
  String? reviews,
  String? subject,
}) =>
    InstructorModelStruct(
      image: image,
      name: name,
      students: students,
      courses: courses,
      reviews: reviews,
      subject: subject,
    );
