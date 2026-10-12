import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/pages/components/main_component/main_component_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'all_courses_page_model.dart';
export 'all_courses_page_model.dart';

class AllCoursesPageWidget extends StatefulWidget {
  const AllCoursesPageWidget({
    super.key,
    this.initialCategory,
  });

  final String? initialCategory;

  static String routeName = 'AllCoursesPage';
  static String routePath = '/allCoursesPage';

  @override
  State<AllCoursesPageWidget> createState() => _AllCoursesPageWidgetState();
}

class _AllCoursesPageWidgetState extends State<AllCoursesPageWidget> {
  late AllCoursesPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllCoursesPageModel());
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _model.selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<RecommendedForYouModelStruct> _filterCourses(
    List<RecommendedForYouModelStruct> pool,
  ) {
    var list = pool;

    // Filter by category
    if (_model.selectedCategory != 'all') {
      final selectedCatLower = _model.selectedCategory.trim().toLowerCase();
      list = list.where((c) {
        final subjectLower = (c.subject).trim().toLowerCase();
        final titleLower = (c.title).trim().toLowerCase();
        final subtitleLower = (c.subtitle).trim().toLowerCase();
        return subjectLower.contains(selectedCatLower) ||
            titleLower.contains(selectedCatLower) ||
            subtitleLower.contains(selectedCatLower);
      }).toList();
    }

    // Filter by search query
    final query = (_model.searchController?.text ?? '').trim().toLowerCase();
    if (query.isNotEmpty) {
      final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
      list = list.where((c) {
        final haystack = '${c.title} ${c.subtitle} ${c.instructorName} ${c.subject}'
            .toLowerCase();
        return tokens.every((token) => haystack.contains(token));
      }).toList();
    }

    // Sort
    if (_model.selectedSort == 'rating') {
      list = List.of(list)..sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_model.selectedSort == 'price_asc') {
      list = List.of(list)..sort((a, b) {
        final priceA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final allCourses = FFAppState().allCoursesList;
    final categories = FFAppState().categoriesList;
    final filteredCourses = _filterCourses(allCourses);

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
              // Top AppBar with Back button
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: FFLocalizations.getText(context, 'all_courses'),
                  isBack: true,
                  isEdit: false,
                  backAction: () async {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(HomeMainPageWidget.routeName);
                    }
                  },
                  editAction: () async {},
                ),
              ),

              // Search Bar inside page
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 12.0),
                child: Container(
                  width: double.infinity,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: theme.lightGray,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: theme.alternate.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20.0,
                        color: theme.secondaryText,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _model.searchController,
                          focusNode: _model.searchFocusNode,
                          onChanged: (_) => safeSetState(() {}),
                          decoration: InputDecoration(
                            hintText: FFLocalizations.getText(context, 'search_courses'),
                            hintStyle: theme.bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              color: theme.secondaryText,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: theme.primaryText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if ((_model.searchController?.text ?? '').isNotEmpty)
                        InkWell(
                          onTap: () {
                            _model.searchController?.clear();
                            safeSetState(() {});
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.0,
                            color: theme.secondaryText,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Category Filter Chips (Horizontally Scrollable)
              SizedBox(
                height: 38.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final catName = isAll ? 'all' : categories[index - 1].name;
                    final displayName = isAll
                        ? FFLocalizations.getText(context, 'all')
                        : categories[index - 1].name;
                    final isSelected = _model.selectedCategory.toLowerCase() ==
                        catName.toLowerCase();

                    return InkWell(
                      borderRadius: BorderRadius.circular(20.0),
                      onTap: () {
                        safeSetState(() {
                          _model.selectedCategory = catName;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primary
                              : theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isSelected
                                ? theme.primary
                                : theme.alternate.withValues(alpha: 0.8),
                            width: 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.primary.withValues(alpha: 0.25),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayName,
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF Pro Display',
                            color: isSelected ? Colors.white : theme.primaryText,
                            fontSize: 13.0,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Counter & Sort bar
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredCourses.length} ${FFLocalizations.getText(context, 'courses_available')}',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF Pro Display',
                        color: theme.secondaryText,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Quick sort menu
                    PopupMenuButton<String>(
                      initialValue: _model.selectedSort,
                      onSelected: (sort) {
                        safeSetState(() {
                          _model.selectedSort = sort;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: theme.secondaryBackground,
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 16.0,
                            color: theme.primary,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            _model.selectedSort == 'rating'
                                ? FFLocalizations.getText(context, 'reviews')
                                : _model.selectedSort == 'price_asc'
                                    ? FFLocalizations.getText(context, 'price')
                                    : FFLocalizations.getText(context, 'all'),
                            style: theme.bodyMedium.override(
                              fontFamily: 'SF Pro Display',
                              color: theme.primary,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'default',
                          child: Text(
                            FFLocalizations.getText(context, 'all'),
                            style: TextStyle(
                              color: theme.primaryText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'rating',
                          child: Text(
                            FFLocalizations.getText(context, 'reviews'),
                            style: TextStyle(
                              color: theme.primaryText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'price_asc',
                          child: Text(
                            FFLocalizations.getText(context, 'price'),
                            style: TextStyle(
                              color: theme.primaryText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Course Grid / Empty state
              Expanded(
                child: RefreshIndicator(
                  color: theme.primary,
                  onRefresh: () async {
                    try {
                      await actions.loadCatalog(forceRefresh: true);
                    } catch (_) {}
                    safeSetState(() {});
                  },
                  child: filteredCourses.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72.0,
                                    height: 72.0,
                                    decoration: BoxDecoration(
                                      color: theme.lightGray,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.school_outlined,
                                      size: 36.0,
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    FFLocalizations.getText(context, 'no_courses'),
                                    textAlign: TextAlign.center,
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'No courses match your filter.',
                                    textAlign: TextAlign.center,
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 14.0,
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      safeSetState(() {
                                        _model.selectedCategory = 'all';
                                        _model.searchController?.clear();
                                        _model.selectedSort = 'default';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                    ),
                                    child: Text(
                                      FFLocalizations.getText(context, 'reset'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 24.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Wrap(
                              spacing: 16.0,
                              runSpacing: 16.0,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              direction: Axis.horizontal,
                              children: List.generate(filteredCourses.length, (index) {
                                final courseItem = filteredCourses[index];
                                final cardWidth = () {
                                  final screenW = MediaQuery.sizeOf(context).width;
                                  if (screenW < 810.0) {
                                    return ((screenW - 56.0) * 1 / 2);
                                  } else if (screenW < 1280.0) {
                                    return ((screenW - 88.0) * 1 / 4);
                                  } else {
                                    return ((screenW - 120.0) * 1 / 6);
                                  }
                                }();

                                return wrapWithModel(
                                  model: _model.mainComponentModels.getModel(
                                    '${courseItem.id}_$index',
                                    index,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: MainComponentWidget(
                                    key: Key('AllCourse_${courseItem.id}_$index'),
                                    image: courseItem.image,
                                    name: courseItem.title,
                                    price: courseItem.price,
                                    review: courseItem.rating.toStringAsFixed(1),
                                    profilePath: courseItem.profileImage,
                                    instructorName: courseItem.instructorName,
                                    subname: courseItem.subtitle,
                                    subject: courseItem.subject,
                                    width: cardWidth,
                                    onTap: () async {
                                      context.pushNamed(
                                        CourseDetailPageWidget.routeName,
                                        queryParameters: {
                                          'detail': serializeParam(
                                            courseItem,
                                            ParamType.DataStruct,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
