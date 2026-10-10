import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/center_appbar/center_appbar_widget.dart';
import '/pages/components/completed_component/completed_component_widget.dart';
import '/pages/components/ongoing_component/ongoing_component_widget.dart';
import '/pages/empty_components/no_completed_dialog/no_completed_dialog_widget.dart';
import '/pages/empty_components/no_ongoing_dialog/no_ongoing_dialog_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'my_course_component_widget.dart' show MyCourseComponentWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class MyCourseComponentModel extends FlutterFlowModel<MyCourseComponentWidget> {
  ///  Local state fields for this component.

  int? selectedTabIndex = 0;
  bool isLoading = false;
  String loadError = '';

  ///  State fields for stateful widgets in this component.

  // Model for CenterAppbar component.
  late CenterAppbarModel centerAppbarModel;
  // Models for OngoingComponent dynamic component.
  late FlutterFlowDynamicModels<OngoingComponentModel> ongoingComponentModels;
  // Model for NoOngoingDialog component.
  late NoOngoingDialogModel noOngoingDialogModel;
  // Models for CompletedComponent dynamic component.
  late FlutterFlowDynamicModels<CompletedComponentModel>
      completedComponentModels;
  // Model for NoCompletedDialog component.
  late NoCompletedDialogModel noCompletedDialogModel;

  @override
  void initState(BuildContext context) {
    centerAppbarModel = createModel(context, () => CenterAppbarModel());
    ongoingComponentModels =
        FlutterFlowDynamicModels(() => OngoingComponentModel());
    noOngoingDialogModel = createModel(context, () => NoOngoingDialogModel());
    completedComponentModels =
        FlutterFlowDynamicModels(() => CompletedComponentModel());
    noCompletedDialogModel =
        createModel(context, () => NoCompletedDialogModel());
  }

  @override
  void dispose() {
    centerAppbarModel.dispose();
    ongoingComponentModels.dispose();
    noOngoingDialogModel.dispose();
    completedComponentModels.dispose();
    noCompletedDialogModel.dispose();
  }
}
