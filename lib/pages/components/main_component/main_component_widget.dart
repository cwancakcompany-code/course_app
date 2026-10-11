import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    final rawWidth = widget.width ?? 224.0;
    // Provide comfortable modern width for title, subtitle, and instructor details
    final cardWidth = (rawWidth > 0 && rawWidth < 210.0) ? 216.0 : rawWidth;

    final title = valueOrDefault<String>(widget.name, '');
    final subtitle = valueOrDefault<String>(widget.subname, '').trim();
    final instructor = valueOrDefault<String>(widget.instructorName, '').trim();
    final price = valueOrDefault<String>(widget.price, '');
    final subject = valueOrDefault<String>(widget.subject, '');
    final ratingRaw = valueOrDefault<String>(widget.review, '0');
    final ratingNum = double.tryParse(ratingRaw) ?? 0;
    final rating = ratingNum > 0 ? ratingNum.toStringAsFixed(1) : '4.8';
    final avatar = (widget.profilePath ?? '').trim();

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: cardWidth,
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.alternate.withValues(alpha: 0.65),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryText.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              splashColor: theme.primary.withValues(alpha: 0.08),
              highlightColor: theme.primary.withValues(alpha: 0.04),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              onTap: () async {
                await widget.onTap?.call();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Cover Thumbnail & Floating Badges ---
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(17),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.55,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _CoverImage(url: widget.image),
                          // Subtle Dark Gradient Overlay for Contrast
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                          // Floating Glassmorphic Rating Badge (Top Right)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.40),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 13,
                                        color: Color(0xFFFFB800),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating,
                                        style: const TextStyle(
                                          fontFamily: 'SF Pro Display',
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Glassmorphic / Gradient Subject Pill (Bottom Left)
                          if (subject.isNotEmpty)
                            Positioned(
                              left: 8,
                              bottom: 8,
                              right: 48,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primary,
                                        theme.primary.withValues(alpha: 0.85),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primary.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    subject,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      color: Colors.white,
                                      fontSize: 10,
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // --- Details Content ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Title
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            fontSize: 14.0,
                            letterSpacing: -0.15,
                            fontWeight: FontWeight.w700,
                            lineHeight: 1.25,
                            color: theme.primaryText,
                          ),
                        ),

                        // Course Subtitle
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              fontSize: 11.5,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w400,
                              lineHeight: 1.25,
                              color: theme.secondaryText,
                            ),
                          ),
                        ],

                        const SizedBox(height: 9),

                        // Instructor Info (Always showing real instructor photo and name)
                        Row(
                          children: [
                            _InstructorAvatar(
                              url: avatar,
                              instructorName: instructor,
                              theme: theme,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                instructor.isNotEmpty ? instructor : 'Instructor',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyMedium.override(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 12.0,
                                  letterSpacing: 0,
                                  color: theme.primaryText.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w600,
                                  lineHeight: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Bottom Row: Price & Subtle Action Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              price.isNotEmpty ? price : 'Free',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                fontSize: 14.5,
                                letterSpacing: -0.2,
                                fontWeight: FontWeight.w800,
                                color: theme.primary,
                                lineHeight: 1.1,
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: theme.primary,
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
          ),
        ),
      ),
    );
  }
}

class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({
    required this.url,
    required this.instructorName,
    required this.theme,
  });

  final String url;
  final String instructorName;
  final FlutterFlowTheme theme;

  static const List<String> _fallbackAvatars = [
    'assets/images/Ellipse_898_(8)1.png',
    'assets/images/Mentors2.png',
    'assets/images/Ellipse_898_(6)1.png',
    'assets/images/Ellipse_898_(7)1.png',
    'assets/images/Ellipse_898_(9)1.png',
    'assets/images/Ellipse_898_(10)1.png',
    'assets/images/Ellipse_898_(11)1.png',
    'assets/images/Ellipse_898_(12)1.png',
    'assets/images/Ellipse_898_(13)1.png',
    'assets/images/Ellipse_900.png',
  ];

  String _getFallbackAsset() {
    final hash = instructorName.isEmpty
        ? 0
        : instructorName.codeUnits.fold(0, (acc, c) => acc + c);
    return _fallbackAvatars[hash % _fallbackAvatars.length];
  }

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    final fallback = _getFallbackAsset();

    Widget imageWidget;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      imageWidget = CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: 80,
        errorWidget: (_, __, ___) => Image.asset(
          fallback,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: theme.black10,
        ),
      );
    } else if (url.startsWith('assets/')) {
      imageWidget = Image.asset(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          fallback,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // url is empty or unresolvable - use real instructor portrait
      imageWidget = Image.asset(
        fallback,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: imageWidget,
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
    if (resolved.startsWith('assets/')) {
      return Image.asset(
        resolved,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
      );
    }
    return CachedNetworkImage(
      imageUrl: resolved,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: const Duration(milliseconds: 200),
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
            theme.primary.withValues(alpha: 0.15),
            theme.secondaryBackground,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 32,
          color: theme.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
