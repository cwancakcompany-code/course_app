import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import '/pages/components/row_component/row_component_widget.dart';
import '/pages/dialog_components/filter_sheet/filter_sheet_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'explore_component_widget.dart' show ExploreComponentWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ExploreComponentModel extends FlutterFlowModel<ExploreComponentWidget> {
  ///  State fields for stateful widgets in this component.

  // Models for CategoryComponent dynamic component.
  late FlutterFlowDynamicModels<CategoryComponentModel> categoryComponentModels;
  // Model for RowComponent component.
  late RowComponentModel rowComponentModel1;
  // Models for MainComponent dynamic component.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModels1;
  // Model for RowComponent component.
  late RowComponentModel rowComponentModel2;
  // Models for MainComponent dynamic component.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModels2;
  // Model for All Courses RowComponent.
  late RowComponentModel rowComponentModelAllCourses;
  // Models for All Courses MainComponent.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModelsAllCourses;

  @override
  void initState(BuildContext context) {
    categoryComponentModels =
        FlutterFlowDynamicModels(() => CategoryComponentModel());
    rowComponentModel1 = createModel(context, () => RowComponentModel());
    mainComponentModels1 = FlutterFlowDynamicModels(() => MainComponentModel());
    rowComponentModel2 = createModel(context, () => RowComponentModel());
    mainComponentModels2 = FlutterFlowDynamicModels(() => MainComponentModel());
    rowComponentModelAllCourses = createModel(context, () => RowComponentModel());
    mainComponentModelsAllCourses = FlutterFlowDynamicModels(() => MainComponentModel());
  }

  @override
  void dispose() {
    categoryComponentModels.dispose();
    rowComponentModel1.dispose();
    mainComponentModels1.dispose();
    rowComponentModel2.dispose();
    mainComponentModels2.dispose();
    rowComponentModelAllCourses.dispose();
    mainComponentModelsAllCourses.dispose();
  }
}
