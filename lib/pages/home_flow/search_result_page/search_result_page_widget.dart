import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/cat_related_component/cat_related_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'search_result_page_model.dart';
export 'search_result_page_model.dart';

class SearchResultPageWidget extends StatefulWidget {
  const SearchResultPageWidget({super.key});

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
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: ' ',
                  isBack: false,
                  isEdit: false,
                  backAction: () async {},
                  editAction: () async {},
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (FFAppState().connected) {
                      return Builder(
                        builder: (context) {
                          final categoryList =
                              FFAppState().popularCoursesList.toList();

                          return ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              20.0,
                              0,
                              20.0,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: categoryList.length,
                            separatorBuilder: (_, __) => SizedBox(height: 16.0),
                            itemBuilder: (context, categoryListIndex) {
                              final categoryListItem =
                                  categoryList[categoryListIndex];
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: wrapWithModel(
                                  model:
                                      _model.catRelatedComponentModels.getModel(
                                    categoryListItem.title,
                                    categoryListIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: CatRelatedComponentWidget(
                                    key: Key(
                                      'Keyv6t_${categoryListItem.title}',
                                    ),
                                    image: categoryListItem.image,
                                    title: categoryListItem.title,
                                    description: categoryListItem.subtitle,
                                    price: categoryListItem.price,
                                    averageReview: categoryListItem.rating,
                                    onTap: () async {
                                      context.pushNamed(
                                        CourseDetailPageWidget.routeName,
                                        queryParameters: {
                                          'detail': serializeParam(
                                            categoryListItem,
                                            ParamType.DataStruct,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Lottie.asset(
                          'assets/jsons/No_Wifi.json',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.contain,
                          animate: true,
                        ),
                      );
                    }
                  },
                ),
              ),
            ].addToStart(SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
