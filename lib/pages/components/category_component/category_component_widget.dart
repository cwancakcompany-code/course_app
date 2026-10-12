import '/backend/media/category_icon_mapper.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'category_component_model.dart';
export 'category_component_model.dart';

class CategoryComponentWidget extends StatefulWidget {
  const CategoryComponentWidget({
    super.key,
    required this.image,
    required this.name,
    required this.tapAction,
    required this.width,
  });

  /// Lucide icon token, optional `icon|#RRGGBB`, or network image URL.
  final String? image;
  final String? name;
  final Future Function()? tapAction;
  final double? width;

  @override
  State<CategoryComponentWidget> createState() =>
      _CategoryComponentWidgetState();
}

class _CategoryComponentWidgetState extends State<CategoryComponentWidget> {
  late CategoryComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final rawImage = (widget.image ?? '').trim();
    final token = rawImage.split('|').first.trim();
    final defaultBg = theme.lightGray;
    final defaultIconColor = theme.primary;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.tapAction?.call();
      },
      child: SizedBox(
        width: widget.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: defaultBg,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: _buildCategoryIcon(context, token, defaultIconColor),
            ),
            const SizedBox(height: 6),
            Text(
              valueOrDefault<String>(widget.name, 'Name'),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: 'SF Pro Display',
                fontSize: 12,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                lineHeight: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    String image,
    Color iconColor,
  ) {
    final isNetwork =
        image.startsWith('http://') || image.startsWith('https://');

    if (image.isNotEmpty && isNetwork && image.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        image,
        width: 26,
        height: 26,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          CategoryIconMapper.toIconData(image),
          size: 26,
          color: iconColor,
        ),
      );
    }

    if (image.isNotEmpty && isNetwork) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          image,
          width: 26,
          height: 26,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            CategoryIconMapper.toIconData(null),
            size: 26,
            color: iconColor,
          ),
        ),
      );
    }

    return Icon(
      CategoryIconMapper.toIconData(image),
      size: 26,
      color: iconColor,
    );
  }
}
