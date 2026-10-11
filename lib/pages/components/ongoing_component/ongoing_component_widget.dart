import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'ongoing_component_model.dart';
export 'ongoing_component_model.dart';

class OngoingComponentWidget extends StatefulWidget {
  const OngoingComponentWidget({
    super.key,
    required this.image,
    required this.name,
    required this.time,
    required this.totalCourse,
    required this.running,
    required this.onTap,
  });

  final String? image;
  final String? name;
  final String? time;
  final int? totalCourse;
  final int? running;
  final Future Function()? onTap;

  @override
  State<OngoingComponentWidget> createState() => _OngoingComponentWidgetState();
}

class _OngoingComponentWidgetState extends State<OngoingComponentWidget> {
  late OngoingComponentModel _model;
  bool _pressed = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OngoingComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final total = (widget.totalCourse != null && widget.totalCourse! > 0)
        ? widget.totalCourse!
        : 1;
    final current = widget.running ?? 0;
    final progress = (current / total).clamp(0.0, 1.0);
    final percentageInt = (progress * 100).toInt();

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
                  // Course Thumbnail
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
                          // Subtle dark overlay
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

                  // Course Info & Progress
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valueOrDefault<String>(widget.name, 'Course Title'),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            fontSize: 15.0,
                            letterSpacing: -0.1,
                            fontWeight: FontWeight.w700,
                            lineHeight: 1.25,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 5.0),
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
                                  fontSize: 12.5,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 1.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                '$percentageInt%',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: LinearPercentIndicator(
                                  percent: progress,
                                  lineHeight: 6.0,
                                  animation: true,
                                  animateFromLastPercent: true,
                                  progressColor: theme.primary,
                                  backgroundColor: theme.alternate.withValues(alpha: 0.6),
                                  barRadius: const Radius.circular(6.0),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              '$current/$total',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                color: theme.secondaryText,
                                fontSize: 11.5,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.2,
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
