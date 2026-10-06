import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'categories_page_widget.dart' show CategoriesPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CategoriesPageModel extends FlutterFlowModel<CategoriesPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MainAppbar component.
  late MainAppbarModel mainAppbarModel;
  // Models for CategoryComponent dynamic component.
  late FlutterFlowDynamicModels<CategoryComponentModel> categoryComponentModels;

  @override
  void initState(BuildContext context) {
    mainAppbarModel = createModel(context, () => MainAppbarModel());
    categoryComponentModels =
        FlutterFlowDynamicModels(() => CategoryComponentModel());
  }

  @override
  void dispose() {
    mainAppbarModel.dispose();
    categoryComponentModels.dispose();
  }
}
