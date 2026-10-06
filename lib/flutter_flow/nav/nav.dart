import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => SplashPageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => SplashPageWidget(),
        ),
        FFRoute(
          name: SplashPageWidget.routeName,
          path: SplashPageWidget.routePath,
          builder: (context, params) => SplashPageWidget(),
        ),
        FFRoute(
          name: OnboardingPageWidget.routeName,
          path: OnboardingPageWidget.routePath,
          builder: (context, params) => OnboardingPageWidget(),
        ),
        FFRoute(
          name: SignInPageWidget.routeName,
          path: SignInPageWidget.routePath,
          builder: (context, params) => SignInPageWidget(
            isInner: params.getParam(
              'isInner',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: SignUpPageWidget.routeName,
          path: SignUpPageWidget.routePath,
          builder: (context, params) => SignUpPageWidget(
            isInner: params.getParam(
              'isInner',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: AboutUsPageWidget.routeName,
          path: AboutUsPageWidget.routePath,
          builder: (context, params) => AboutUsPageWidget(),
        ),
        FFRoute(
          name: SearchPageWidget.routeName,
          path: SearchPageWidget.routePath,
          builder: (context, params) => SearchPageWidget(),
        ),
        FFRoute(
          name: DemoPageWidget.routeName,
          path: DemoPageWidget.routePath,
          builder: (context, params) => DemoPageWidget(),
        ),
        FFRoute(
          name: HomeMainPageWidget.routeName,
          path: HomeMainPageWidget.routePath,
          builder: (context, params) => HomeMainPageWidget(),
        ),
        FFRoute(
          name: ForgotPasswordPageWidget.routeName,
          path: ForgotPasswordPageWidget.routePath,
          builder: (context, params) => ForgotPasswordPageWidget(),
        ),
        FFRoute(
          name: ForgotVerificationsPageWidget.routeName,
          path: ForgotVerificationsPageWidget.routePath,
          builder: (context, params) => ForgotVerificationsPageWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ResetPasswordPageWidget.routeName,
          path: ResetPasswordPageWidget.routePath,
          builder: (context, params) => ResetPasswordPageWidget(),
        ),
        FFRoute(
          name: TermsConditionPageWidget.routeName,
          path: TermsConditionPageWidget.routePath,
          builder: (context, params) => TermsConditionPageWidget(),
        ),
        FFRoute(
          name: PrivacyPolicyPageWidget.routeName,
          path: PrivacyPolicyPageWidget.routePath,
          builder: (context, params) => PrivacyPolicyPageWidget(),
        ),
        FFRoute(
          name: PasswordManagerPageWidget.routeName,
          path: PasswordManagerPageWidget.routePath,
          builder: (context, params) => PasswordManagerPageWidget(),
        ),
        FFRoute(
          name: SettingsPageWidget.routeName,
          path: SettingsPageWidget.routePath,
          builder: (context, params) => SettingsPageWidget(),
        ),
        FFRoute(
          name: EditProfilePageWidget.routeName,
          path: EditProfilePageWidget.routePath,
          builder: (context, params) => EditProfilePageWidget(),
        ),
        FFRoute(
          name: ChatDetailsPageWidget.routeName,
          path: ChatDetailsPageWidget.routePath,
          builder: (context, params) => ChatDetailsPageWidget(
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            name: params.getParam(
              'name',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: NotificationPageWidget.routeName,
          path: NotificationPageWidget.routePath,
          builder: (context, params) => NotificationPageWidget(),
        ),
        FFRoute(
          name: SearchResultPageWidget.routeName,
          path: SearchResultPageWidget.routePath,
          builder: (context, params) => SearchResultPageWidget(),
        ),
        FFRoute(
          name: CategoriesPageWidget.routeName,
          path: CategoriesPageWidget.routePath,
          builder: (context, params) => CategoriesPageWidget(),
        ),
        FFRoute(
          name: RecommendedForYouPageWidget.routeName,
          path: RecommendedForYouPageWidget.routePath,
          builder: (context, params) => RecommendedForYouPageWidget(),
        ),
        FFRoute(
          name: PopularCoursesPageWidget.routeName,
          path: PopularCoursesPageWidget.routePath,
          builder: (context, params) => PopularCoursesPageWidget(),
        ),
        FFRoute(
          name: InstructorPageWidget.routeName,
          path: InstructorPageWidget.routePath,
          builder: (context, params) => InstructorPageWidget(),
        ),
        FFRoute(
          name: InstructorDetailPageWidget.routeName,
          path: InstructorDetailPageWidget.routePath,
          builder: (context, params) => InstructorDetailPageWidget(
            instructorDetail: params.getParam(
              'instructorDetail',
              ParamType.DataStruct,
              isList: false,
              structBuilder: InstructorModelStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: CategoryRelatedPageWidget.routeName,
          path: CategoryRelatedPageWidget.routePath,
          builder: (context, params) => CategoryRelatedPageWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: CourseDetailPageWidget.routeName,
          path: CourseDetailPageWidget.routePath,
          builder: (context, params) => CourseDetailPageWidget(
            detail: params.getParam(
              'detail',
              ParamType.DataStruct,
              isList: false,
              structBuilder: RecommendedForYouModelStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: PaymentMethodPagePurchaseWidget.routeName,
          path: PaymentMethodPagePurchaseWidget.routePath,
          builder: (context, params) => PaymentMethodPagePurchaseWidget(
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            subtitle: params.getParam(
              'subtitle',
              ParamType.String,
            ),
            price: params.getParam(
              'price',
              ParamType.String,
            ),
            instructorName: params.getParam(
              'instructorName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AddCardPagePurchaseWidget.routeName,
          path: AddCardPagePurchaseWidget.routePath,
          builder: (context, params) => AddCardPagePurchaseWidget(
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            subtitle: params.getParam(
              'subtitle',
              ParamType.String,
            ),
            price: params.getParam(
              'price',
              ParamType.String,
            ),
            instructorName: params.getParam(
              'instructorName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ReviewSummaryPageWidget.routeName,
          path: ReviewSummaryPageWidget.routePath,
          builder: (context, params) => ReviewSummaryPageWidget(
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            subtitle: params.getParam(
              'subtitle',
              ParamType.String,
            ),
            price: params.getParam(
              'price',
              ParamType.String,
            ),
            way: params.getParam(
              'way',
              ParamType.String,
            ),
            instructorName: params.getParam(
              'instructorName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: EReciptPageWidget.routeName,
          path: EReciptPageWidget.routePath,
          builder: (context, params) => EReciptPageWidget(
            instructorName: params.getParam(
              'instructorName',
              ParamType.String,
            ),
            price: params.getParam(
              'price',
              ParamType.String,
            ),
            way: params.getParam(
              'way',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: VideoPlayerPageWidget.routeName,
          path: VideoPlayerPageWidget.routePath,
          builder: (context, params) => VideoPlayerPageWidget(),
        ),
        FFRoute(
          name: RecentlyAddedPageWidget.routeName,
          path: RecentlyAddedPageWidget.routePath,
          builder: (context, params) => RecentlyAddedPageWidget(),
        ),
        FFRoute(
          name: SuggestionForYouPageWidget.routeName,
          path: SuggestionForYouPageWidget.routePath,
          builder: (context, params) => SuggestionForYouPageWidget(),
        ),
        FFRoute(
          name: VerificationsPageWidget.routeName,
          path: VerificationsPageWidget.routePath,
          builder: (context, params) => VerificationsPageWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
      observers: ffNavigatorObservers,
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
