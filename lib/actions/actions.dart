import '/backend/schema/structs/index.dart';
import '/backend/ui/app_notify.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

Future addAndRemoveFavourite(
  BuildContext context, {
  required bool? isAvilable,
  required RecommendedForYouModelStruct? product,
}) async {
  if (isAvilable!) {
    FFAppState().removeFromFavouriteList(product!);
    FFAppState().update(() {});
    AppNotify.info(context, FFAppState().unfavText);
  } else {
    FFAppState().addToFavouriteList(product!);
    FFAppState().update(() {});
    AppNotify.success(context, FFAppState().favText);
  }
}

Future internetSnackbar(BuildContext context) async {
  AppNotify.warning(context, 'Please turn on internet...');
}

Future mainSnackbar(
  BuildContext context, {
  required String? title,
}) async {
  AppNotify.info(context, title ?? '');
}
