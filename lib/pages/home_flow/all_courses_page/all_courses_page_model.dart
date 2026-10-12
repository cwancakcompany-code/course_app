import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import 'package:flutter/material.dart';
import 'all_courses_page_widget.dart' show AllCoursesPageWidget;

class AllCoursesPageModel extends FlutterFlowModel<AllCoursesPageWidget> {
  // Model for MainAppbar component.
  late MainAppbarModel mainAppbarModel;

  // Search field controller and focus node.
  TextEditingController? searchController;
  FocusNode? searchFocusNode;

  // Selected category filter ('all' for everything).
  String selectedCategory = 'all';

  // Sort option: 'default', 'rating', 'price_asc', 'price_desc'
  String selectedSort = 'default';

  // Dynamic models for course cards.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModels;

  @override
  void initState(BuildContext context) {
    mainAppbarModel = createModel(context, () => MainAppbarModel());
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    mainComponentModels = FlutterFlowDynamicModels(() => MainComponentModel());
  }

  @override
  void dispose() {
    mainAppbarModel.dispose();
    searchController?.dispose();
    searchFocusNode?.dispose();
    mainComponentModels.dispose();
  }
}
