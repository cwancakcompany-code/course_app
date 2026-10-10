import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/category_component/category_component_widget.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'categories_page_model.dart';
export 'categories_page_model.dart';

class CategoriesPageWidget extends StatefulWidget {
  const CategoriesPageWidget({super.key});

  static String routeName = 'CategoriesPage';
  static String routePath = '/categoriesPage';

  @override
  State<CategoriesPageWidget> createState() => _CategoriesPageWidgetState();
}

class _CategoriesPageWidgetState extends State<CategoriesPageWidget> {
  late CategoriesPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoriesPageModel());
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
                  title: 'Categories',
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
                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          20.0,
                          0,
                          20.0,
                        ),
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                38.0, 0.0, 38.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final cat =
                                    FFAppState().categoriesList.toList();

                                return Wrap(
                                  spacing: 51.0,
                                  runSpacing: 16.0,
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  direction: Axis.horizontal,
                                  runAlignment: WrapAlignment.start,
                                  verticalDirection: VerticalDirection.down,
                                  clipBehavior: Clip.none,
                                  children:
                                      List.generate(cat.length, (catIndex) {
                                    final catItem = cat[catIndex];
                                    return wrapWithModel(
                                      model: _model.categoryComponentModels
                                          .getModel(
                                        catItem.name,
                                        catIndex,
                                      ),
                                      updateCallback: () => safeSetState(() {}),
                                      child: CategoryComponentWidget(
                                        key: Key(
                                          'Keyqia_${catItem.name}',
                                        ),
                                        image: catItem.image,
                                        name: catItem.name,
                                        width: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              810.0) {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    178) *
                                                1 /
                                                3);
                                          } else if ((MediaQuery.sizeOf(context)
                                                      .width >=
                                                  810.0) &&
                                              (MediaQuery.sizeOf(context)
                                                      .width <
                                                  1280.0)) {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    331) *
                                                1 /
                                                6);
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width >=
                                              1280.0) {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    484) *
                                                1 /
                                                9);
                                          } else {
                                            return ((MediaQuery.sizeOf(context)
                                                        .width -
                                                    637) *
                                                1 /
                                                12);
                                          }
                                        }(),
                                        tapAction: () async {
                                          final categoryId = catIndex <
                                                  FFAppState()
                                                      .categoryIds
                                                      .length
                                              ? FFAppState()
                                                  .categoryIds[catIndex]
                                              : '';
                                          context.pushNamed(
                                            CategoryRelatedPageWidget.routeName,
                                            queryParameters: {
                                              'title': serializeParam(
                                                catItem.name,
                                                ParamType.String,
                                              ),
                                              'categoryId': serializeParam(
                                                categoryId,
                                                ParamType.String,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
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
