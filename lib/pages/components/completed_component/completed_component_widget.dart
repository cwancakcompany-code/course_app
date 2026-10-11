import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'completed_component_model.dart';
export 'completed_component_model.dart';

class CompletedComponentWidget extends StatefulWidget {
  const CompletedComponentWidget({
    super.key,
    required this.image,
    required this.name,
    required this.time,
    this.onTap,
  });

  final String? image;
  final String? name;
  final String? time;
  final Future Function()? onTap;

  @override
  State<CompletedComponentWidget> createState() =>
      _CompletedComponentWidgetState();
}

class _CompletedComponentWidgetState extends State<CompletedComponentWidget> {
  late CompletedComponentModel _model;
  bool _pressed = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompletedComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: theme.alternate.withValues(alpha: 0.65),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryText.withValues(alpha: 0.04),
              blurRadius: 14.0,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(18.0),
            splashColor: theme.primary.withValues(alpha: 0.08),
            highlightColor: theme.primary.withValues(alpha: 0.04),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: () async {
              await widget.onTap?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.0),
                    child: Container(
                      width: 92.0,
                      height: 84.0,
                      color: theme.black10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            fadeInDuration: const Duration(milliseconds: 200),
                            fadeOutDuration: const Duration(milliseconds: 200),
                            imageUrl: widget.image ?? '',
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) => Container(
                              color: theme.primary.withValues(alpha: 0.12),
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 30.0,
                                color: theme.primary.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12.0),

                  // Info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valueOrDefault<String>(widget.name, 'Course Title'),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            fontSize: 14.5,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w700,
                            lineHeight: 1.25,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13.0,
                              color: theme.secondaryText,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                valueOrDefault<String>(widget.time, '0h 0m'),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyMedium.override(
                                  fontFamily: 'SF Pro Display',
                                  color: theme.secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  // Completed Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 20.0,
                        ),
                        SizedBox(height: 2.0),
                        Text(
                          '100%',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
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
