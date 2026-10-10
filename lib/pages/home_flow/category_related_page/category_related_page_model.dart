import '/backend/mappers/catalog_mappers.dart';
import '/backend/schema/structs/index.dart';
import '/backend/services/catalog_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import 'category_related_page_widget.dart' show CategoryRelatedPageWidget;
import 'package:flutter/material.dart';

class CategoryRelatedPageModel
    extends FlutterFlowModel<CategoryRelatedPageWidget> {
  late MainAppbarModel mainAppbarModel;
  late FlutterFlowDynamicModels<CatRelatedComponentModel>
      catRelatedComponentModels;

  bool loading = false;
  String error = '';
  List<RecommendedForYouModelStruct> courses = [];

  Future<void> loadCourses({
    required String? categoryId,
    required String? title,
  }) async {
    loading = true;
    error = '';
    try {
      final service = CatalogService();
      if (categoryId != null && categoryId.isNotEmpty) {
        final rows = await service.loadCoursesByCategory(categoryId);
        courses = rows.map(CatalogMappers.toCourseStruct).toList();
      } else if (title != null && title.trim().isNotEmpty) {
        // Fallback: resolve id from loaded catalog names.
        final app = FFAppState();
        final index = app.categoriesList.indexWhere((c) => c.name == title);
        if (index >= 0 && index < app.categoryIds.length) {
          final rows =
              await service.loadCoursesByCategory(app.categoryIds[index]);
          courses = rows.map(CatalogMappers.toCourseStruct).toList();
        } else {
          courses = [];
        }
      } else {
        courses = [];
      }
    } catch (e) {
      error = e.toString();
      courses = [];
    } finally {
      loading = false;
    }
  }

  @override
  void initState(BuildContext context) {
    mainAppbarModel = createModel(context, () => MainAppbarModel());
    catRelatedComponentModels =
        FlutterFlowDynamicModels(() => CatRelatedComponentModel());
  }

  @override
  void dispose() {
    mainAppbarModel.dispose();
    catRelatedComponentModels.dispose();
  }
}
