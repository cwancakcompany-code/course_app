import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '/backend/media/bunny_stream_service.dart';

/// Plays Bunny Stream via signed iframe embed (same approach as admin panel).
class BunnyPlayerWidget extends StatefulWidget {
  const BunnyPlayerWidget({
    super.key,
    this.width,
    this.height,
    required this.videoRef,
    this.autoplay = true,
  });

  final double? width;
  final double? height;
  final String videoRef;
  final bool autoplay;

  @override
  State<BunnyPlayerWidget> createState() => _BunnyPlayerWidgetState();
}

class _BunnyPlayerWidgetState extends State<BunnyPlayerWidget> {
  WebViewController? _controller;
  String? _error;
  bool _loading = true;
  bool _pageReady = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BunnyPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoRef != widget.videoRef ||
        oldWidget.autoplay != widget.autoplay) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _pageReady = false;
    });

    try {
      final bunny = BunnyStreamService();
      final videoId = bunny.extractVideoId(widget.videoRef);
      if (videoId == null) {
        throw StateError('Invalid Bunny video reference');
      }

      final embedUrl = bunny.signedEmbedUrl(
        videoId,
        autoplay: widget.autoplay,
      );
      debugPrint('Bunny embed: $embedUrl');

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (!mounted) return;
              setState(() {
                _loading = false;
                _pageReady = true;
                // Clear DNS blips from Bunny CDN subresources.
                _error = null;
              });
            },
            onWebResourceError: (error) {
              // Bunny iframe loads many CDNs; ignore subresource / DNS blips.
              final isMain = error.isForMainFrame ?? false;
              final desc = error.description;
              debugPrint(
                'Bunny WebView error (main=$isMain): $desc',
              );
              final isDns = desc.toUpperCase().contains('NAME_NOT_RESOLVED') ||
                  desc.toUpperCase().contains('ERR_NAME_NOT_RESOLVED');
              if (!isMain || _pageReady || isDns) return;
              if (mounted) {
                setState(() {
                  _loading = false;
                  _error = desc;
                });
              }
            },
          ),
        );

      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        platform.setMediaPlaybackRequiresUserGesture(false);
      }

      await controller.loadRequest(Uri.parse(embedUrl));

      if (!mounted) return;
      setState(() {
        _controller = controller;
      });
    } catch (e) {
      debugPrint('Bunny player load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null) WebViewWidget(controller: _controller!),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_error != null && !_loading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'نەتوانرا ڤیدیۆی Bunny بکرێتەوە\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
