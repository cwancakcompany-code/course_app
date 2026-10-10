import '/backend/schema/structs/recommended_for_you_model_struct.dart';
import '/backend/utils/course_search.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'search_page_model.dart';
export 'search_page_model.dart';

class SearchPageWidget extends StatefulWidget {
  const SearchPageWidget({super.key});

  static String routeName = 'SearchPage';
  static String routePath = '/searchPage';

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {
  late SearchPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchPageModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;

    final history = FFAppState().searchList;
    if (!history.contains(query)) {
      FFAppState().addToSearchList(query);
    }
    FFAppState().lastSearchQuery = query;
    FFAppState().update(() {});

    context.pushNamed(
      SearchResultPageWidget.routeName,
      queryParameters: {
        'query': serializeParam(query, ParamType.String),
      }.withoutNulls,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final query = (_model.textController?.text ?? '').trim();
    final pool = CourseSearch.catalogPool(
      recommended: FFAppState().recommendedForYouList,
      popular: FFAppState().popularCoursesList,
    );
    final List<RecommendedForYouModelStruct> liveResults = query.isEmpty
        ? const <RecommendedForYouModelStruct>[]
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
                  title: 'Search',
                  isBack: false,
                  isEdit: false,
                  backAction: () async {},
                  editAction: () async {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/search.svg',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => EasyDebounce.debounce(
                            'search_live',
                            const Duration(milliseconds: 200),
                            () => safeSetState(() {}),
                          ),
                          onFieldSubmitted: _submitSearch,
                          decoration: InputDecoration(
                            isDense: false,
                            hintText: 'Search courses...',
                            hintStyle: theme.labelMedium.override(
                              fontFamily: 'SF Pro Display',
                              fontSize: 17,
                              letterSpacing: 0,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsetsDirectional.fromSTEB(
                              12,
                              16,
                              12,
                              16,
                            ),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _model.textController?.clear();
                                      safeSetState(() {});
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: theme.primaryText,
                                    ),
                                  )
                                : null,
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17,
                            letterSpacing: 0,
                          ),
                          cursorColor: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (query.isEmpty && FFAppState().searchList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent',
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: theme.secondaryText,
                            fontSize: 17,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          FFAppState().deleteSearchList();
                          FFAppState().searchList = [];
                          FFAppState().update(() {});
                        },
                        child: Text(
                          'Clear All',
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: theme.primary,
                            fontSize: 16,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (query.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    liveResults.isEmpty
                        ? 'No courses found'
                        : '${liveResults.length} results',
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF Pro Display',
                      color: theme.secondaryText,
                      fontSize: 15,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              Expanded(
                child: query.isEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                        itemCount: FFAppState().searchList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = FFAppState().searchList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: InkWell(
                              onTap: () => _submitSearch(item),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 20,
                                    color: theme.secondaryText,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: theme.bodyMedium.override(
                                        fontFamily: 'SF Pro Display',
                                        fontSize: 15,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FFAppState()
                                          .removeAtIndexFromSearchList(index);
                                      FFAppState().update(() {});
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/closeBlack.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        itemCount: liveResults.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final course = liveResults[index];
                          return CatRelatedComponentWidget(
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
