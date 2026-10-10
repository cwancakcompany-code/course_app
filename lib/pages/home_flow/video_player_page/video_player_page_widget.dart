import '/backend/media/bunny_stream_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'video_player_page_model.dart';
export 'video_player_page_model.dart';

class VideoPlayerPageWidget extends StatefulWidget {
  const VideoPlayerPageWidget({
    super.key,
    this.videoUrl,
  });

  /// Bunny GUID, signed/unsigned mediadelivery URL, or direct https media URL.
  final String? videoUrl;

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
    final raw = widget.videoUrl?.trim() ?? '';
    final bunny = BunnyStreamService();
    final isBunny = bunny.extractVideoId(raw) != null ||
        raw.contains('mediadelivery.net');

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
            children: [
              Row(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async => context.safePop(),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).lightGray,
                        shape: BoxShape.circle,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/images/arrow_back_appbar_ic.svg',
                          width: 24.0,
                          height: 24.0,
                          fit: BoxFit.none,
                        ),
                      ),
                    ),
                  ),
                ].addToStart(const SizedBox(width: 20.0)),
              ),
              Expanded(
                child: raw.isEmpty
                    ? Center(
                        child: Text(
                          'ڤیدیۆ بەردەست نییە',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Display',
                                    color: Colors.white,
                                    letterSpacing: 0,
                                  ),
                        ),
                      )
                    : isBunny
                        ? custom_widgets.BunnyPlayerWidget(
                            width: double.infinity,
                            height: double.infinity,
                            videoRef: raw,
                            autoplay: true,
                          )
                        : custom_widgets.VideoPlayerWidget(
                            width: double.infinity,
                            height: double.infinity,
                            videoUrl: raw,
                            autoPlay: true,
                            looping: false,
                            showControls: true,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
