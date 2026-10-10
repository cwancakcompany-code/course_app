import 'package:flutter/material.dart';

/// Maps Lucide-style icon names stored in `categories.icon_url` to Material icons.
class CategoryIconMapper {
  const CategoryIconMapper._();

  static IconData toIconData(String? raw) {
    final key = (raw ?? '').trim().toLowerCase();
    switch (key) {
      case 'heartpulse':
      case 'heart':
      case 'activity':
        return Icons.favorite_outline;
      case 'laptop':
      case 'monitor':
      case 'computer':
        return Icons.laptop_mac_outlined;
      case 'code':
      case 'code2':
      case 'terminal':
        return Icons.code;
      case 'briefcase':
      case 'business':
        return Icons.work_outline;
      case 'palette':
      case 'paintbrush':
      case 'design':
        return Icons.palette_outlined;
      case 'camera':
      case 'aperture':
        return Icons.photo_camera_outlined;
      case 'music':
      case 'music2':
        return Icons.music_note_outlined;
      case 'book':
      case 'bookopen':
        return Icons.menu_book_outlined;
      case 'cpu':
      case 'bot':
      case 'sparkles':
        return Icons.memory;
      case 'languages':
      case 'globe':
        return Icons.language;
      default:
        return Icons.category_outlined;
    }
  }
}
