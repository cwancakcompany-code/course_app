import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future addAndRemoveFavourite(
  BuildContext context, {
  required bool? isAvilable,
  required RecommendedForYouModelStruct? product,
}) async {
  if (isAvilable!) {
    FFAppState().removeFromFavouriteList(product!);
    FFAppState().update(() {});
    await action_blocks.mainSnackbar(
      context,
      title: FFAppState().unfavText,
    );
  } else {
    FFAppState().addToFavouriteList(product!);
    FFAppState().update(() {});
    await action_blocks.mainSnackbar(
      context,
      title: FFAppState().favText,
    );
  }
}

Future internetSnackbar(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Please turn on internet...',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          color: FlutterFlowTheme.of(context).primaryText,
          fontSize: 17.0,
        ),
      ),
      duration: Duration(milliseconds: 2000),
      backgroundColor: FlutterFlowTheme.of(context).secondary,
    ),
  );
}

Future mainSnackbar(
  BuildContext context, {
  required String? title,
}) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        title!,
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          color: FlutterFlowTheme.of(context).primaryText,
          fontSize: 17.0,
        ),
      ),
      duration: Duration(milliseconds: 2000),
      backgroundColor: FlutterFlowTheme.of(context).secondary,
    ),
  );
}
