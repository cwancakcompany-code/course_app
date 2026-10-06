import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/review_component/review_component_widget.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'course_detail_page_widget.dart' show CourseDetailPageWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CourseDetailPageModel extends FlutterFlowModel<CourseDetailPageWidget> {
  ///  Local state fields for this page.

  int? selectedIndex = 0;

  ///  State fields for stateful widgets in this page.

  // Models for ReviewComponent dynamic component.
  late FlutterFlowDynamicModels<ReviewComponentModel> reviewComponentModels;

  @override
  void initState(BuildContext context) {
    reviewComponentModels =
        FlutterFlowDynamicModels(() => ReviewComponentModel());
  }

  @override
  void dispose() {
    reviewComponentModels.dispose();
  }
}
