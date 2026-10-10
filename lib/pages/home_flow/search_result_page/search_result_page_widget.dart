import '/backend/utils/course_search.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'search_result_page_model.dart';
export 'search_result_page_model.dart';

class SearchResultPageWidget extends StatefulWidget {
  const SearchResultPageWidget({
    super.key,
    this.query,
  });

  final String? query;

  static String routeName = 'SearchResultPage';
  static String routePath = '/searchResultPage';

  @override
  State<SearchResultPageWidget> createState() => _SearchResultPageWidgetState();
}

class _SearchResultPageWidgetState extends State<SearchResultPageWidget> {
  late SearchResultPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final query = (widget.query?.trim().isNotEmpty == true
            ? widget.query!.trim()
            : FFAppState().lastSearchQuery)
        .trim();

    final pool = CourseSearch.catalogPool(
      recommended: FFAppState().recommendedForYouList,
      popular: FFAppState().popularCoursesList,
    );
    final results = query.isEmpty
        ? pool
        : CourseSearch.filter(pool, query);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: query.isEmpty ? 'Search' : query,
                  isBack: false,
                  isEdit: false,
                  backAction: () async {},
                  editAction: () async {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  results.isEmpty
                      ? 'No courses found for "$query"'
                      : '${results.length} courses',
                  style: theme.bodyMedium.override(
                    fontFamily: 'SF Pro Display',
                    color: theme.secondaryText,
                    fontSize: 15,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Expanded(
                child: !FFAppState().connected
                    ? Align(
                        alignment: Alignment.center,
                        child: Lottie.asset(
                          'assets/jsons/No_Wifi.json',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          animate: true,
                        ),
                      )
                    : results.isEmpty
                        ? Center(
                            child: Text(
                              'Try another keyword',
                              style: theme.bodyMedium.override(
                                fontFamily: 'SF Pro Display',
                                color: theme.secondaryText,
                                fontSize: 16,
                                letterSpacing: 0,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            itemCount: results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final course = results[index];
                              return wrapWithModel(
                                model: _model.catRelatedComponentModels
                                    .getModel(
                                  course.id.isNotEmpty
                                      ? course.id
                                      : '${course.title}_$index',
                                  index,
                                ),
                                updateCallback: () => safeSetState(() {}),
                                child: CatRelatedComponentWidget(
                                  key: Key(
                                    'search_${course.id}_$index',
                                  ),
                                  image: course.image,
                                  title: course.title,
                                  description: course.subtitle,
                                  price: course.price,
                                  averageReview: course.rating,
                                  onTap: () async {
                                    context.pushNamed(
                                      CourseDetailPageWidget.routeName,
                                      queryParameters: {
                                        'detail': serializeParam(
                                          course,
                                          ParamType.DataStruct,
                                        ),
                                      }.withoutNulls,
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
