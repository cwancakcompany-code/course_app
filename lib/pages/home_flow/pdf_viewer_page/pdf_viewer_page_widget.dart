import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '/backend/ui/app_notify.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PdfViewerPageWidget extends StatefulWidget {
  const PdfViewerPageWidget({
    super.key,
    this.pdfUrl,
    this.title,
  });

  final String? pdfUrl;
  final String? title;

  static String routeName = 'PdfViewerPage';
  static String routePath = '/pdfViewerPage';

  @override
  State<PdfViewerPageWidget> createState() => _PdfViewerPageWidgetState();
}

class _PdfViewerPageWidgetState extends State<PdfViewerPageWidget> {
  String? _localPath;
  String? _error;
  bool _loading = true;
  int _pages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final url = (widget.pdfUrl ?? '').trim();
    if (url.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'PDF بەردەست نییە';
      });
      return;
    }
    if (kIsWeb) {
      setState(() {
        _loading = false;
        _error = 'خوێندنەوەی PDF لە وێب پشتگیری ناکرێت';
      });
      return;
    }

    try {
      final uri = Uri.parse(url);
      final dir = await getTemporaryDirectory();
      final fileName =
          'lesson_${uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'doc.pdf'}';
      final safeName = fileName.toLowerCase().endsWith('.pdf')
          ? fileName
          : '$fileName.pdf';
      final file = File('${dir.path}/$safeName');

      if (!await file.exists() || await file.length() < 64) {
        final res = await http.get(uri);
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw StateError('Download failed (${res.statusCode})');
        }
        await file.writeAsBytes(res.bodyBytes, flush: true);
      }

      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('PDF prepare failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'نەتوانرا PDF بکرێتەوە';
      });
      AppNotify.error(context, 'نەتوانرا PDF بکرێتەوە');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final title = (widget.title ?? '').trim().isEmpty
        ? 'PDF'
        : widget.title!.trim();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyMedium.override(
            fontFamily: 'SF Pro Display',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        actions: [
          if (_pages > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1}/$_pages',
                  style: theme.bodyMedium.override(
                    fontFamily: 'SF Pro Display',
                    fontSize: 13,
                    color: theme.secondaryText,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium,
                    ),
                  ),
                )
              : PDFView(
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  onRender: (pages) {
                    setState(() => _pages = pages ?? 0);
                  },
                  onPageChanged: (page, total) {
                    setState(() {
                      _currentPage = page ?? 0;
                      _pages = total ?? _pages;
                    });
                  },
                  onError: (e) {
                    debugPrint('PDFView error: $e');
                    setState(() => _error = 'PDF هەڵەیە');
                  },
                  onPageError: (page, e) {
                    debugPrint('PDF page $page error: $e');
                  },
                ),
    );
  }
}
