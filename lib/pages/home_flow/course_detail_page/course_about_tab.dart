import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class CourseAboutTab extends StatelessWidget {
  const CourseAboutTab({
    super.key,
    required this.description,
    this.subtitle,
    this.level,
  });

  final String description;
  final String? subtitle;
  final String? level;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final body = description.trim().isNotEmpty
        ? description.trim()
        : (subtitle?.trim().isNotEmpty == true
            ? subtitle!.trim()
            : 'هیچ وەسفێک بۆ ئەم کۆرسە تۆمار نەکراوە.');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      primary: false,
      shrinkWrap: true,
      children: [
        if (level != null && level!.trim().isNotEmpty) ...[
          Text(
            'ئاست: ${level!.trim()}',
            style: theme.bodyMedium.override(
              fontFamily: 'SF Pro Display',
              fontSize: 15,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          body,
          style: theme.bodyMedium.override(
            fontFamily: 'SF Pro Display',
            fontSize: 17,
            letterSpacing: 0,
            fontWeight: FontWeight.normal,
            lineHeight: 1.4,
          ),
        ),
      ],
    );
  }
}
