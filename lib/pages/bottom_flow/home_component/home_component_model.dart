import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import '/pages/components/row_component/row_component_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'home_component_widget.dart' show HomeComponentWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeComponentModel extends FlutterFlowModel<HomeComponentWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 1;

  // Model for RowComponent component.
  late RowComponentModel rowComponentModel1;
  // Models for CategoryComponent dynamic component.
  late FlutterFlowDynamicModels<CategoryComponentModel> categoryComponentModels;
  // Model for RowComponent component.
  late RowComponentModel rowComponentModel2;
  // Models for MainComponent dynamic component.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModels1;
  // Model for RowComponent component.
  late RowComponentModel rowComponentModel3;
  // Models for MainComponent dynamic component.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModels2;
  // Model for RowComponent component.
  late RowComponentModel rowComponentModel4;
  // Model for All Courses RowComponent.
  late RowComponentModel rowComponentModelAllCourses;
  // Models for All Courses MainComponent.
  late FlutterFlowDynamicModels<MainComponentModel> mainComponentModelsAllCourses;

  @override
  void initState(BuildContext context) {
    rowComponentModel1 = createModel(context, () => RowComponentModel());
    categoryComponentModels =
        FlutterFlowDynamicModels(() => CategoryComponentModel());
    rowComponentModel2 = createModel(context, () => RowComponentModel());
    mainComponentModels1 = FlutterFlowDynamicModels(() => MainComponentModel());
    rowComponentModel3 = createModel(context, () => RowComponentModel());
    mainComponentModels2 = FlutterFlowDynamicModels(() => MainComponentModel());
    rowComponentModel4 = createModel(context, () => RowComponentModel());
    rowComponentModelAllCourses = createModel(context, () => RowComponentModel());
    mainComponentModelsAllCourses = FlutterFlowDynamicModels(() => MainComponentModel());
  }

  @override
  void dispose() {
    rowComponentModel1.dispose();
    categoryComponentModels.dispose();
    rowComponentModel2.dispose();
    mainComponentModels1.dispose();
    rowComponentModel3.dispose();
    mainComponentModels2.dispose();
    rowComponentModel4.dispose();
    rowComponentModelAllCourses.dispose();
    mainComponentModelsAllCourses.dispose();
  }
}
