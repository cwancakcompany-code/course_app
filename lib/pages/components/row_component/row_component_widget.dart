import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'row_component_model.dart';
export 'row_component_model.dart';

class RowComponentWidget extends StatefulWidget {
  const RowComponentWidget({
    super.key,
    required this.title,
    bool? isShow,
    required this.viewAllAction,
  }) : this.isShow = isShow ?? false;

  final String? title;
  final bool isShow;
  final Future Function()? viewAllAction;

  @override
  State<RowComponentWidget> createState() => _RowComponentWidgetState();
}

class _RowComponentWidgetState extends State<RowComponentWidget> {
  late RowComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RowComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.title ?? 'Title';
    final localizedTitle = FFLocalizations.getText(context, titleText.toLowerCase().replaceAll(' ', '_'));
    final displayTitle = localizedTitle != titleText.toLowerCase().replaceAll(' ', '_')
        ? localizedTitle
        : titleText;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            displayTitle,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  lineHeight: 1.5,
                ),
          ),
        ),
        if (widget!.isShow)
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              await widget.viewAllAction?.call();
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  FFLocalizations.getText(context, 'see_all'),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Display',
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                      ),
                ),
                Transform.flip(
                  flipX: FFLocalizations.isRTL,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: SvgPicture.asset(
                      'assets/images/arrow-right_primary_learnify.svg',
                      width: 16.0,
                      height: 16.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ].divide(SizedBox(width: 6.0)),
            ),
          ),
      ].divide(SizedBox(width: 12.0)),
    );
  }
}
