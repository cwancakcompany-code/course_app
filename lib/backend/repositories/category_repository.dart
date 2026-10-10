import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/models/category_entity.dart';
import '/backend/supabase/supabase_bootstrap.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> fetchActive({int limit = 50});
}

class SupabaseCategoryRepository implements CategoryRepository {
  SupabaseCategoryRepository({SupabaseClient? client})
      : _client = client ?? SupabaseBootstrap.client;

  final SupabaseClient _client;

  @override
  Future<List<CategoryEntity>> fetchActive({int limit = 50}) async {
    final rows = await _client
        .from('categories')
        .select('id, name, icon_url, color_hex, sort_order')
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .limit(limit);

    return (rows as List)
        .map((row) => CategoryEntity.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
