import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'search_result_page_widget.dart' show SearchResultPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SearchResultPageModel extends FlutterFlowModel<SearchResultPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MainAppbar component.
  late MainAppbarModel mainAppbarModel;
  // Models for CatRelatedComponent dynamic component.
  late FlutterFlowDynamicModels<CatRelatedComponentModel>
      catRelatedComponentModels;

  @override
  void initState(BuildContext context) {
    mainAppbarModel = createModel(context, () => MainAppbarModel());
    catRelatedComponentModels =
        FlutterFlowDynamicModels(() => CatRelatedComponentModel());
  }

  @override
  void dispose() {
    mainAppbarModel.dispose();
    catRelatedComponentModels.dispose();
  }
}
