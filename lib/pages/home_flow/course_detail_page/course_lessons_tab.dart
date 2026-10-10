import 'package:flutter/material.dart';

import '/backend/models/course_section_entity.dart';
import '/backend/ui/app_notify.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class CourseLessonsTab extends StatelessWidget {
  const CourseLessonsTab({
    super.key,
    required this.sections,
    required this.lessonsCount,
    this.isEnrolled = false,
  });

  final List<CourseSectionEntity> sections;
  final int lessonsCount;
  final bool isEnrolled;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          isEnrolled
              ? 'هیچ وانەیەک بۆ ئەم کۆرسە زیاد نەکراوە.'
              : 'وانەکان دوای چالاککردنی کۆرسەکە بۆ هەژمارەکەت دەردەکەون.',
          style: theme.bodyMedium.override(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            letterSpacing: 0,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      primary: false,
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          child: Text(
            'Lessons ($lessonsCount)',
            style: theme.bodyMedium.override(
              fontFamily: 'SF Pro Display',
              fontSize: 16,
              letterSpacing: 0,
              lineHeight: 1.5,
            ),
          ),
        ),
        if (!isEnrolled)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
            child: Text(
              'تەنها وانەی free preview دەکرێت ببینرێت تا کۆرسەکە بۆت چالاک بکرێت.',
              style: theme.bodyMedium.override(
                fontFamily: 'SF Pro Display',
                color: theme.secondaryText,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
          ),
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF Pro Display',
                      fontSize: 15,
                      letterSpacing: 0,
                      lineHeight: 1.5,
                    ),
                  ),
                ),
                if (section.durationMinutes > 0)
                  Text(
                    '${section.durationMinutes} Min',
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF Pro Display',
                      color: theme.primary,
                      fontSize: 15,
                      letterSpacing: 0,
                      lineHeight: 1.5,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
            child: Column(
              children: [
                for (final lesson in section.lessons)
                  InkWell(
                    onTap: () {
                      final canPlay = isEnrolled || lesson.isFreePreview;
                      if (!canPlay) {
                        AppNotify.warning(
                          context,
                          'ئەم وانەیە تەنها دوای چالاککردنی کۆرسەکە دەکرێت ببینرێت',
                        );
                        return;
                      }
                      final videoRef = lesson.videoUrl?.trim() ?? '';
                      if (videoRef.isEmpty) {
                        AppNotify.info(context, 'ڤیدیۆی ئەم وانەیە ئامادە نییە');
                        return;
                      }
                      context.pushNamed(
                        VideoPlayerPageWidget.routeName,
                        queryParameters: {
                          'videoUrl':
                              serializeParam(videoRef, ParamType.String),
                        }.withoutNulls,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            (isEnrolled || lesson.isFreePreview)
                                ? Icons.play_circle_fill_rounded
                                : Icons.lock_rounded,
                            size: 32,
                            color: (isEnrolled || lesson.isFreePreview)
                                ? theme.primary
                                : theme.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lesson.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                fontSize: 17,
                                letterSpacing: 0,
                                lineHeight: 1.4,
                              ),
                            ),
                          ),
                          if (lesson.isFreePreview && !isEnrolled)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: Text(
                                'Preview',
                                style: theme.bodyMedium.override(
                                  fontFamily: 'SF Pro Display',
                                  color: theme.primary,
                                  fontSize: 12,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (lesson.durationSeconds > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(lesson.durationSeconds),
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                color: theme.secondaryText,
                                fontSize: 15,
                                letterSpacing: 0,
                                lineHeight: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final rm = m % 60;
      return '$h:${rm.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
