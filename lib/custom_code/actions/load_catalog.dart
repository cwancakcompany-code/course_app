import 'package:flutter/foundation.dart';

import '/app_state.dart';
import '/backend/mappers/catalog_mappers.dart';
import '/backend/services/catalog_service.dart';

Future loadCatalog({bool forceRefresh = false}) async {
  final appState = FFAppState();
  if (appState.catalogLoading) return;

  appState.update(() {
    appState.catalogLoading = true;
    appState.catalogError = '';
  });

  try {
    final snapshot = await CatalogService().loadHomeCatalog(
      forceRefresh: forceRefresh,
    );

    appState.update(() {
      appState.categoriesList = snapshot.categories
          .map(CatalogMappers.toCategoryStruct)
          .toList();
      appState.instructorList = snapshot.instructors
          .map(CatalogMappers.toInstructorStruct)
          .toList();
      appState.recommendedForYouList = snapshot.recommended
          .map(CatalogMappers.toCourseStruct)
          .toList();
      appState.popularCoursesList = snapshot.popular
          .map(CatalogMappers.toCourseStruct)
          .toList();
      appState.catalogCourseIds = {
        for (final course in snapshot.recommended) course.id: course.id,
        for (final course in snapshot.popular) course.id: course.id,
        for (final course in snapshot.recent) course.id: course.id,
      };
      appState.recommendedCourseIds =
          snapshot.recommended.map((c) => c.id).toList();
      appState.popularCourseIds = snapshot.popular.map((c) => c.id).toList();
      appState.categoryIds = snapshot.categories.map((c) => c.id).toList();
      appState.instructorIds = snapshot.instructors.map((c) => c.id).toList();
      appState.catalogLoaded = true;
      appState.catalogLoading = false;
    });
  } catch (e) {
    appState.update(() {
      appState.catalogLoading = false;
      appState.catalogError = e.toString();
    });
    // Keep app usable; lists may be partially empty when RLS blocks courses.
    debugPrint('loadCatalog error: $e');
  }
}
