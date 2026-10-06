import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/pages/components/review_component/review_component_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'instructor_detail_page_widget.dart' show InstructorDetailPageWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class InstructorDetailPageModel
    extends FlutterFlowModel<InstructorDetailPageWidget> {
  ///  Local state fields for this page.

  int? selectedIndex = 0;

  ///  State fields for stateful widgets in this page.

  // Model for MainAppbar component.
  late MainAppbarModel mainAppbarModel;
  // Models for CatRelatedComponent dynamic component.
  late FlutterFlowDynamicModels<CatRelatedComponentModel>
      catRelatedComponentModels;
  // Models for ReviewComponent dynamic component.
  late FlutterFlowDynamicModels<ReviewComponentModel> reviewComponentModels;

  @override
  void initState(BuildContext context) {
    mainAppbarModel = createModel(context, () => MainAppbarModel());
    catRelatedComponentModels =
        FlutterFlowDynamicModels(() => CatRelatedComponentModel());
    reviewComponentModels =
        FlutterFlowDynamicModels(() => ReviewComponentModel());
  }

  @override
  void dispose() {
    mainAppbarModel.dispose();
    catRelatedComponentModels.dispose();
    reviewComponentModels.dispose();
  }
}
