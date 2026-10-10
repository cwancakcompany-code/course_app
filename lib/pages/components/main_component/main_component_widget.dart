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
  bool _pressed = false;

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
    final cardWidth = widget.width ?? 176.0;
    final title = valueOrDefault<String>(widget.name, '');
    final instructor = valueOrDefault<String>(widget.instructorName, '');
    final price = valueOrDefault<String>(widget.price, '');
    final subject = valueOrDefault<String>(widget.subject, '');
    final ratingRaw = valueOrDefault<String>(widget.review, '0');
    final ratingNum = double.tryParse(ratingRaw) ?? 0;
    final rating = ratingNum.toStringAsFixed(1);
    final avatar = (widget.profilePath ?? '').trim();

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: SizedBox(
        width: cardWidth,
        child: Material(
          color: theme.secondaryBackground,
          elevation: 0,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: theme.primary.withValues(alpha: 0.08),
            highlightColor: theme.primary.withValues(alpha: 0.04),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: () async {
              await widget.onTap?.call();
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.alternate.withValues(alpha: 0.85),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryText.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _CoverImage(url: widget.image),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.45),
                                ],
                                stops: const [0, 0.45, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                                      Color(0xFFF5A623),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating,
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'SF Pro Display',
                                      color: const Color(0xFF1A1A1A),
                                      fontSize: 11,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (subject.isNotEmpty)
                            Positioned(
                              left: 8,
                              bottom: 8,
                              right: 8,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primary.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    subject,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'SF Pro Display',
                                      color: Colors.white,
                                      fontSize: 10,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 36,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              fontSize: 14,
                              letterSpacing: -0.1,
                              fontWeight: FontWeight.w700,
                              lineHeight: 1.25,
                              color: theme.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (instructor.isNotEmpty || avatar.isNotEmpty)
                          Row(
                            children: [
                              _InstructorAvatar(url: avatar, theme: theme),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  instructor.isNotEmpty
                                      ? instructor
                                      : 'Instructor',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.bodyMedium.override(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 12,
                                    letterSpacing: 0,
                                    color: theme.secondaryText,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox(height: 20),
                        if (price.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              fontSize: 14,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              color: theme.primary,
                              lineHeight: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({required this.url, required this.theme});

  final String url;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.secondary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_rounded,
          size: 12,
          color: theme.primary,
        ),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: 64,
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: theme.secondary,
          alignment: Alignment.center,
          child: Icon(Icons.person_rounded, size: 12, color: theme.primary),
        ),
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: theme.black10,
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
      fadeInDuration: const Duration(milliseconds: 220),
      fadeOutDuration: const Duration(milliseconds: 180),
      memCacheWidth: 560,
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
    final theme = FlutterFlowTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.secondary,
            theme.black10,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 34,
          color: theme.primary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
