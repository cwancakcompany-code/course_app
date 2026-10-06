import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom_flow/chats_component/chats_component_widget.dart';
import '/pages/bottom_flow/explore_component/explore_component_widget.dart';
import '/pages/bottom_flow/home_component/home_component_widget.dart';
import '/pages/bottom_flow/my_course_component/my_course_component_widget.dart';
import '/pages/bottom_flow/profile_component/profile_component_widget.dart';
import 'dart:ui';
import 'home_main_page_widget.dart' show HomeMainPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeMainPageModel extends FlutterFlowModel<HomeMainPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for HomeComponent component.
  late HomeComponentModel homeComponentModel;
  // Model for ExploreComponent component.
  late ExploreComponentModel exploreComponentModel;
  // Model for MyCourseComponent component.
  late MyCourseComponentModel myCourseComponentModel;
  // Model for ChatsComponent component.
  late ChatsComponentModel chatsComponentModel;
  // Model for ProfileComponent component.
  late ProfileComponentModel profileComponentModel;

  @override
  void initState(BuildContext context) {
    homeComponentModel = createModel(context, () => HomeComponentModel());
    exploreComponentModel = createModel(context, () => ExploreComponentModel());
    myCourseComponentModel =
        createModel(context, () => MyCourseComponentModel());
    chatsComponentModel = createModel(context, () => ChatsComponentModel());
    profileComponentModel = createModel(context, () => ProfileComponentModel());
  }

  @override
  void dispose() {
    homeComponentModel.dispose();
    exploreComponentModel.dispose();
    myCourseComponentModel.dispose();
    chatsComponentModel.dispose();
    profileComponentModel.dispose();
  }
}
