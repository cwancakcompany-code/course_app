import '/backend/services/realtime_sync_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'category_related_page_model.dart';
export 'category_related_page_model.dart';

class CategoryRelatedPageWidget extends StatefulWidget {
  const CategoryRelatedPageWidget({
    super.key,
    this.title,
    this.categoryId,
  });

  final String? title;
  final String? categoryId;

  static String routeName = 'CategoryRelatedPage';
  static String routePath = '/categoryRelatedPage';

  @override
  State<CategoryRelatedPageWidget> createState() =>
      _CategoryRelatedPageWidgetState();
}

class _CategoryRelatedPageWidgetState extends State<CategoryRelatedPageWidget> {
  late CategoryRelatedPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late VoidCallback _realtimeListener;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryRelatedPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _model.loadCourses(
        categoryId: widget.categoryId,
        title: widget.title,
      );
      if (mounted) safeSetState(() {});
    });

    _realtimeListener = () {
      if (mounted) {
        _model
            .loadCourses(
              categoryId: widget.categoryId,
              title: widget.title,
            )
            .then((_) {
          if (mounted) safeSetState(() {});
        });
      }
    };
    RealtimeSyncService().courseUpdateNotifier.addListener(_realtimeListener);
  }

  @override
  void dispose() {
    RealtimeSyncService().courseUpdateNotifier.removeListener(_realtimeListener);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: widget.title ?? '',
                  isBack: true,
                  isEdit: false,
                  backAction: () async {},
                  editAction: () async {},
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (!FFAppState().connected) {
                      return Align(
                        alignment: Alignment.center,
                        child: Lottie.asset(
                          'assets/jsons/No_Wifi.json',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.contain,
                          animate: true,
                        ),
                      );
                    }

                    if (_model.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categoryList = _model.courses;
                    if (categoryList.isEmpty) {
                      return Center(
                        child: Text(
                          'هیچ کۆرسێک لەم پۆلەدا نییە',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Display',
                                    letterSpacing: 0,
                                  ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 0.0),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        itemCount: categoryList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = categoryList[index];
                          return wrapWithModel(
                            model: _model.catRelatedComponentModels.getModel(
                              item.id.isNotEmpty ? item.id : item.title,
                              index,
                            ),
                            updateCallback: () => safeSetState(() {}),
                            child: CatRelatedComponentWidget(
                              key: Key('Keycat_$index'),
                              image: item.image,
                              title: item.title,
                              description: item.subtitle,
                              price: item.price,
                              averageReview: item.rating,
                              onTap: () async {
                                context.pushNamed(
                                  CourseDetailPageWidget.routeName,
                                  queryParameters: {
                                    'detail': serializeParam(
                                      item,
                                      ParamType.DataStruct,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
