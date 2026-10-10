import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';

/// App-wide toast/alert helper backed by `elegant_notification`.
class AppNotify {
  const AppNotify._();

  static double _width(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w - 32).clamp(280.0, 420.0);
  }

  static Widget _title(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      );

  static Widget _body(String text) => Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: const TextStyle(fontSize: 13, height: 1.25),
      );

  static void success(
    BuildContext context,
    String message, {
    String title = 'Success',
  }) {
    if (!context.mounted) return;
    ElegantNotification.success(
      width: _width(context),
      height: null,
      title: _title(title),
      description: _body(message),
      animation: AnimationType.fromTop,
      position: Alignment.topCenter,
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static void error(
    BuildContext context,
    String message, {
    String title = 'Error',
  }) {
    if (!context.mounted) return;
    ElegantNotification.error(
      width: _width(context),
      height: null,
      title: _title(title),
      description: _body(message),
      animation: AnimationType.fromTop,
      position: Alignment.topCenter,
      toastDuration: const Duration(seconds: 5),
    ).show(context);
  }

  static void info(
    BuildContext context,
    String message, {
    String title = 'Info',
  }) {
    if (!context.mounted) return;
    ElegantNotification.info(
      width: _width(context),
      height: null,
      title: _title(title),
      description: _body(message),
      animation: AnimationType.fromTop,
      position: Alignment.topCenter,
      toastDuration: const Duration(seconds: 4),
    ).show(context);
  }

  static void warning(
    BuildContext context,
    String message, {
    String title = 'Warning',
  }) {
    if (!context.mounted) return;
    ElegantNotification(
      width: _width(context),
      height: null,
      title: _title(title),
      description: _body(message),
      icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
      progressIndicatorColor: const Color(0xFFF59E0B),
      animation: AnimationType.fromTop,
      position: Alignment.topCenter,
      toastDuration: const Duration(seconds: 4),
    ).show(context);
  }
}
