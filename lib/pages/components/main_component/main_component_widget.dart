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
    final cardWidth = widget.width ?? 168.0;
    final title = valueOrDefault<String>(widget.name, '');
    final instructor = valueOrDefault<String>(widget.instructorName, '');
    final price = valueOrDefault<String>(widget.price, '');
    final ratingRaw = valueOrDefault<String>(widget.review, '0');
    final ratingNum = double.tryParse(ratingRaw) ?? 0;
    final rating = ratingNum.toStringAsFixed(1);

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.onTap?.call();
      },
      child: SizedBox(
        width: cardWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CoverImage(url: widget.image),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/star.svg',
                              width: 11,
                              height: 11,
                              fit: BoxFit.contain,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFFFC107),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating,
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                lineHeight: 1.25,
              ),
            ),
            if (instructor.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                instructor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium.override(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  letterSpacing: 0,
                  color: theme.secondaryText,
                  lineHeight: 1.2,
                ),
              ),
            ],
            if (price.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium.override(
                  fontFamily: 'SF Pro Display',
                  fontSize: 13,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                  lineHeight: 1.2,
                ),
              ),
            ],
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
      memCacheWidth: 480,
      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
      placeholder: (_, __) => Container(
        color: FlutterFlowTheme.of(context).black10,
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
        size: 32,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }
}
