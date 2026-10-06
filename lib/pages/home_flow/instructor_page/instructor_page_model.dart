import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/instructor_row_component/instructor_row_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'instructor_page_widget.dart' show InstructorPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class InstructorPageModel extends FlutterFlowModel<InstructorPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MainAppbar component.
  late MainAppbarModel mainAppbarModel;
  // Models for InstructorRowComponent dynamic component.
  late FlutterFlowDynamicModels<InstructorRowComponentModel>
      instructorRowComponentModels;

  @override
  void initState(BuildContext context) {
    mainAppbarModel = createModel(context, () => MainAppbarModel());
    instructorRowComponentModels =
        FlutterFlowDynamicModels(() => InstructorRowComponentModel());
  }

  @override
  void dispose() {
    mainAppbarModel.dispose();
    instructorRowComponentModels.dispose();
  }
}
