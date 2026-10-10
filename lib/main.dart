import 'dart:ui' as ui;
import '/backend/supabase/supabase_bootstrap.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import '/flutter_flow/internationalization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await SupabaseBootstrap.initialize();

  // Start initial custom actions code
  await actions.connected();
  await actions.lockOrientation();
  // End initial custom actions code

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  // Prefer live Supabase session over stale local isLogin flag.
  try {
    await actions.syncAuthSession();
  } catch (e) {
    debugPrint('Auth session sync failed: $e');
  }

  // Warm catalog from Supabase (categories, courses, instructors).
  try {
    await actions.loadCatalog();
  } catch (e) {
    debugPrint('Catalog load failed: $e');
  }

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
    final currentLang = appState.appLanguage.isEmpty ? 'ckb' : appState.appLanguage;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduMaster',
      locale: Locale(currentLang),
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        // ckb/ku need Material/Cupertino fallbacks (no built-in catalogs).
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ckb', ''),
        Locale('ku', ''),
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('ckb', '');
      },
      builder: (context, child) {
        final isRTL = currentLang == 'ckb' || currentLang == 'ku' || currentLang == 'ar';
        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: (currentLang == 'ckb' || currentLang == 'ku') ? 'Channel8' : 'SF Pro Display',
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
