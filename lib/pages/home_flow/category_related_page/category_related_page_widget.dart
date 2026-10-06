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
import 'category_related_page_model.dart';
export 'category_related_page_model.dart';

class CategoryRelatedPageWidget extends StatefulWidget {
  const CategoryRelatedPageWidget({
    super.key,
    this.title,
  });

  final String? title;

  static String routeName = 'CategoryRelatedPage';
  static String routePath = '/categoryRelatedPage';

  @override
  State<CategoryRelatedPageWidget> createState() =>
      _CategoryRelatedPageWidgetState();
}

class _CategoryRelatedPageWidgetState extends State<CategoryRelatedPageWidget> {
  late CategoryRelatedPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryRelatedPageModel());
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
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: widget!.title!,
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
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Builder(
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
                              scrollDirection: Axis.vertical,
                              itemCount: categoryList.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 16.0),
                              itemBuilder: (context, categoryListIndex) {
                                final categoryListItem =
                                    categoryList[categoryListIndex];
                                return wrapWithModel(
                                  model:
                                      _model.catRelatedComponentModels.getModel(
                                    categoryListItem.title,
                                    categoryListIndex,
                                  ),
                                  updateCallback: () => safeSetState(() {}),
                                  child: CatRelatedComponentWidget(
                                    key: Key(
                                      'Keyc0h_${categoryListItem.title}',
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
                                );
                              },
                            );
                          },
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
