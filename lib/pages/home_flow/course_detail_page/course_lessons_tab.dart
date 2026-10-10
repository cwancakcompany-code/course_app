import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/backend/models/course_section_entity.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class CourseLessonsTab extends StatelessWidget {
  const CourseLessonsTab({
    super.key,
    required this.sections,
    required this.lessonsCount,
  });

  final List<CourseSectionEntity> sections;
  final int lessonsCount;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'هیچ وانەیەک بۆ ئەم کۆرسە زیاد نەکراوە.',
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
                      final videoRef = lesson.videoUrl?.trim() ?? '';
                      if (videoRef.isEmpty) return;
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
                          SvgPicture.asset(
                            'assets/images/play-circlePurple.svg',
                            width: 32,
                            height: 32,
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
