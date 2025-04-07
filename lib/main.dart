import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/data/api/api_service.dart';
import 'package:storyapp/data/db/auth_repository.dart';
import 'package:storyapp/data/db/story_repository.dart';
import 'package:storyapp/provider/add_story_provider.dart';
import 'package:storyapp/provider/auth_provider.dart';
import 'package:storyapp/provider/localization_provider.dart';
import 'package:storyapp/provider/story_provider.dart';
import 'package:storyapp/provider/theme_provider.dart';
import 'package:storyapp/routes/page_manager.dart';
import 'package:storyapp/routes/router_delegate.dart';
import 'package:storyapp/style/app_theme.dart';
import 'package:storyapp/common.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ApiService()),
        Provider(
          create: (context) => AuthRepository(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (context) => PageManager()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        Provider(
          create:
              (context) =>
                  StoryRepository(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => StoryProvider(
                storyRepository: context.read<StoryRepository>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (context) => AddStoryProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider(create: (context) => LocalizationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate _myRouterDelegate;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    _myRouterDelegate = MyRouterDelegate(context.read<AuthRepository>());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localizationProvider = context.watch<LocalizationProvider>();

    return MaterialApp(
      title: 'Story App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: Router(
        routerDelegate: _myRouterDelegate,
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localizationProvider.locale,
    );
  }
}
