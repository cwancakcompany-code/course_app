import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'completed_component_model.dart';
export 'completed_component_model.dart';

class CompletedComponentWidget extends StatefulWidget {
  const CompletedComponentWidget({
    super.key,
    required this.image,
    required this.name,
    required this.time,
  });

  final String? image;
  final String? name;
  final String? time;

  @override
  State<CompletedComponentWidget> createState() =>
      _CompletedComponentWidgetState();
}

class _CompletedComponentWidgetState extends State<CompletedComponentWidget> {
  late CompletedComponentModel _model;

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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).black20,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 200),
                fadeOutDuration: Duration(milliseconds: 200),
                imageUrl: widget!.image!,
                width: 93.0,
                height: 86.0,
                fit: BoxFit.contain,
                errorWidget: (context, error, stackTrace) => Image.asset(
                  'assets/images/error_image.png',
                  width: 93.0,
                  height: 86.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 8.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget!.name,
                        'Name',
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            lineHeight: 1.4,
                          ),
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget!.time,
                        'Time',
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 17.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            lineHeight: 1.4,
                          ),
                    ),
                  ].divide(SizedBox(height: 14.0)),
                ),
              ),
            ),
            CircularPercentIndicator(
              percent: 1.0,
              radius: 35.0,
              lineWidth: 5.0,
              animation: true,
              animateFromLastPercent: true,
              progressColor: FlutterFlowTheme.of(context).primary,
              backgroundColor: FlutterFlowTheme.of(context).accent4,
              center: Text(
                '100%',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'SF Pro Display',
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ].addToStart(SizedBox(width: 8.0)).addToEnd(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
