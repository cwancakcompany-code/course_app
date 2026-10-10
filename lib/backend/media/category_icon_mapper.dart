import 'package:flutter/material.dart';

/// Maps Lucide-style icon names stored in `categories.icon_url` to Material icons.
class CategoryIconMapper {
  const CategoryIconMapper._();

  static IconData toIconData(String? raw) {
    final key = _normalize(raw);
    if (key.isEmpty) return Icons.category_outlined;

    switch (key) {
      // Medical / health
      case 'stethoscope':
      case 'heartpulse':
      case 'heartbeat':
      case 'heart':
      case 'activity':
      case 'hospital':
      case 'cross':
      case 'pill':
        return Icons.medical_services_outlined;

      // IT / devices
      case 'laptop':
      case 'monitor':
      case 'computer':
      case 'pc':
      case 'smartphone':
      case 'tablet':
        return Icons.laptop_mac_outlined;

      // Coding
      case 'code':
      case 'code2':
      case 'codexml':
      case 'terminal':
      case 'braces':
      case 'filecode':
      case 'filecode2':
      case 'binary':
        return Icons.code;

      // Business
      case 'briefcase':
      case 'business':
      case 'building':
      case 'building2':
      case 'chart':
      case 'barchart':
      case 'piechart':
        return Icons.work_outline;

      // Design
      case 'palette':
      case 'paintbrush':
      case 'paintbrush2':
      case 'design':
      case 'pen':
      case 'pentool':
      case 'figma':
      case 'layers':
        return Icons.palette_outlined;

      // Media
      case 'camera':
      case 'aperture':
      case 'image':
      case 'images':
      case 'video':
        return Icons.photo_camera_outlined;
      case 'music':
      case 'music2':
      case 'music3':
      case 'headphones':
        return Icons.music_note_outlined;

      // Education
      case 'book':
      case 'bookopen':
      case 'bookmarked':
      case 'graduationcap':
      case 'school':
      case 'library':
        return Icons.menu_book_outlined;

      // AI / tech
      case 'cpu':
      case 'bot':
      case 'sparkles':
      case 'brain':
      case 'atom':
      case 'circuitboard':
        return Icons.memory;

      // Language / world
      case 'languages':
      case 'globe':
      case 'earth':
      case 'map':
        return Icons.language;

      // Finance
      case 'wallet':
      case 'creditcard':
      case 'dollar':
      case 'coins':
        return Icons.account_balance_wallet_outlined;

      // Science
      case 'flask':
      case 'flaskconical':
      case 'microscope':
      case 'beaker':
        return Icons.science_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  /// Accepts Lucide names like `CodeXml`, `heart-pulse`, `book_open`.
  static String _normalize(String? raw) {
    return (raw ?? '')
        .trim()
        .split('|')
        .first
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static Color? parseColor(String? hex) {
    if (hex == null) return null;
    var value = hex.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }
}
