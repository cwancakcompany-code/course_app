import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'main_component_model.dart';
export 'main_component_model.dart';

class MainComponentWidget extends StatefulWidget {
  const MainComponentWidget({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.review,
    this.profilePath,
    this.instructorName,
    this.subname,
    this.width,
    this.subject,
    required this.onTap,
  });

  final String? image;
  final String? name;
  final String? price;
  final String? review;
  final String? profilePath;
  final String? instructorName;
  final String? subname;
  final double? width;
  final String? subject;
  final Future Function()? onTap;

  @override
  State<MainComponentWidget> createState() => _MainComponentWidgetState();
}

class _MainComponentWidgetState extends State<MainComponentWidget> {
  late MainComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final cardWidth = widget.width ?? 287.0;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.onTap?.call();
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: theme.black20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: cardWidth,
              height: 148.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverImage(url: widget.image),
                  PositionedDirectional(
                    top: 10,
                    start: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/star.svg',
                            width: 13.0,
                            height: 13.0,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            valueOrDefault<String>(widget.review, '0.0'),
                            maxLines: 1,
                            style: theme.bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueOrDefault<String>(widget.name, ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF Pro Display',
                      color: const Color(0xFF0564F1),
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                      lineHeight: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valueOrDefault<String>(widget.subname, ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF Pro Display',
                      fontSize: 15.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      lineHeight: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Avatar(url: widget.profilePath, size: 32),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              valueOrDefault<String>(
                                widget.instructorName,
                                '',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                fontSize: 13.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.2,
                              ),
                            ),
                            Text(
                              valueOrDefault<String>(widget.subject, ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                                color: theme.secondaryText,
                                lineHeight: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          valueOrDefault<String>(widget.price, ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final resolved = (url ?? '').trim();
    if (resolved.isEmpty) {
      return const _ImagePlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: resolved,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: 600,
      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
      placeholder: (_, __) => Container(
        color: FlutterFlowTheme.of(context).black10,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = (url ?? '').trim();
    final theme = FlutterFlowTheme.of(context);
    if (resolved.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.black10,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: size * 0.55, color: theme.secondaryText),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 150),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: theme.black10,
          child: Icon(
            Icons.person,
            size: size * 0.55,
            color: theme.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).black10,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 40,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }
}
