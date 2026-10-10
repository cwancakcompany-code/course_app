import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cat_related_component_model.dart';
export 'cat_related_component_model.dart';

class CatRelatedComponentWidget extends StatefulWidget {
  const CatRelatedComponentWidget({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    required this.averageReview,
    required this.onTap,
  });

  final String? image;
  final String? title;
  final String? description;
  final String? price;
  final double? averageReview;
  final Future Function()? onTap;

  @override
  State<CatRelatedComponentWidget> createState() =>
      _CatRelatedComponentWidgetState();
}

class _CatRelatedComponentWidgetState extends State<CatRelatedComponentWidget> {
  late CatRelatedComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CatRelatedComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.onTap?.call();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).black20,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: _courseThumb(
                  context,
                  url: widget.image,
                  width: 97.0,
                  height: 99.0,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget!.title,
                        'Title',
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: FlutterFlowTheme.of(context).accent1,
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 8.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget!.description,
                          'Description',
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              fontSize: 17.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              lineHeight: 1.4,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            valueOrDefault<String>(widget.price, ''),
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  lineHeight: 1.5,
                                ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: SvgPicture.asset(
                                'assets/images/star.svg',
                                width: 13.0,
                                height: 13.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Text(
                              valueOrDefault<String>(
                                widget!.averageReview?.toString(),
                                '5',
                              ),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ].divide(SizedBox(width: 4.0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(width: 10.0)),
          ),
        ),
      ),
    );
  }
}

Widget _courseThumb(
  BuildContext context, {
  required String? url,
  required double width,
  required double height,
}) {
  final resolved = (url ?? '').trim();
  if (resolved.isEmpty) {
    return _ThumbPlaceholder(width: width, height: height);
  }
  return SizedBox(
    width: width,
    height: height,
    child: CachedNetworkImage(
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      imageUrl: resolved,
      width: width,
      height: height,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      memCacheWidth: 400,
      errorWidget: (context, error, stackTrace) =>
          _ThumbPlaceholder(width: width, height: height),
      placeholder: (_, __) => _ThumbPlaceholder(width: width, height: height),
    ),
  );
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: FlutterFlowTheme.of(context).black10,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 32,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }
}
