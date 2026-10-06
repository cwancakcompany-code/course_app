import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.tapAction?.call();
      },
      child: Container(
        width: widget!.width,
        height: 106.0,
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).black10,
                shape: BoxShape.circle,
              ),
              alignment: AlignmentDirectional(0.0, 0.0),
              child: SvgPicture.network(
                widget!.image!,
                width: 32.0,
                height: 32.0,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              valueOrDefault<String>(
                widget!.name,
                'Name',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                    lineHeight: 1.5,
                  ),
            ),
          ].divide(SizedBox(height: 2.0)),
        ),
      ),
    );
  }
}
