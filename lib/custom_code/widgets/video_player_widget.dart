// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    this.width,
    this.height,
    this.videoUrl,
    this.autoPlay = false,
    this.looping = true,
    this.showControls = true,
    this.aspectRatio,
  });

  final double? width;
  final double? height;
  final String? videoUrl;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final double? aspectRatio;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeControllers();
      _initializeVideo();
    } else if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.looping != widget.looping ||
        oldWidget.showControls != widget.showControls ||
        oldWidget.aspectRatio != widget.aspectRatio) {
      _updateChewieController();
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = '';
    });

    final videoUrl = widget.videoUrl?.trim() ??
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _videoPlayerController.initialize();
      _updateChewieController();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: ${e.toString()}';
      });
      print('Video player error: $e');
    }
  }

  void _updateChewieController() {
    if (!mounted) return;

    _chewieController?.dispose();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      showControls: widget.showControls,
      aspectRatio:
          widget.aspectRatio ?? _videoPlayerController.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
      placeholder: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black12,
        child: Center(
          child: Text(
            _errorMessage,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      child: Chewie(controller: _chewieController!),
    );
  }
}
