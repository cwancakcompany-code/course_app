import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'video_player_page_model.dart';
export 'video_player_page_model.dart';

class VideoPlayerPageWidget extends StatefulWidget {
  const VideoPlayerPageWidget({super.key});

  static String routeName = 'VideoPlayerPage';
  static String routePath = '/videoPlayerPage';

  @override
  State<VideoPlayerPageWidget> createState() => _VideoPlayerPageWidgetState();
}

class _VideoPlayerPageWidgetState extends State<VideoPlayerPageWidget> {
  late VideoPlayerPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoPlayerPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).black,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.safePop();
                        },
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).lightGray,
                            shape: BoxShape.circle,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: SvgPicture.asset(
                              'assets/images/arrow_back_appbar_ic.svg',
                              width: 24.0,
                              height: 24.0,
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                      ),
                    ].addToStart(SizedBox(width: 20.0)),
                  ),
                ],
              ),
              Expanded(
                child: custom_widgets.VideoPlayerWidget(
                  width: double.infinity,
                  height: 80.0,
                  videoUrl:
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/online-learning-app-r2a86x/assets/a2tvbp0l7xka/videoplayback.mp4',
                  autoPlay: true,
                  looping: true,
                  showControls: true,
                ),
              ),
            ].addToStart(SizedBox(height: 24.0)),
          ),
        ),
      ),
    );
  }
}
