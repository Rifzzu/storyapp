import 'package:flutter/material.dart';
import 'package:storyapp/data/db/auth_repository.dart';
import 'package:storyapp/screen/add_story/add_story_screen.dart';
import 'package:storyapp/screen/detail/detail_screen.dart';
import 'package:storyapp/screen/home/home_screen.dart';
import 'package:storyapp/screen/login/login_screen.dart';
import 'package:storyapp/screen/register/register_screen.dart';
import 'package:storyapp/screen/splash/splash_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  AuthRepository authRepository;

  MyRouterDelegate(this.authRepository)
    : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    isLoggedIn = await authRepository.isLoggedIn();
    notifyListeners();
  }

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  String? selectedStory;
  bool isAddStory = false;

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onDidRemovePage: (page) {
        if (page.key == ValueKey("DetailStoryScreen-$selectedStory")) {
          selectedStory = null;
          notifyListeners();
        } else if (page.key == ValueKey("AddStoryScreen")) {
          isAddStory = false;
          notifyListeners();
        }
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  @override
  Future<void> setNewRoutePath(configuration) {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }

  List<Page> get _splashStack => [
    const MaterialPage(key: ValueKey("SplashScreen"), child: SplashScreen()),
  ];

  List<Page> get _loggedOutStack => [
    MaterialPage(
      key: const ValueKey("LoginScreen"),
      child: LoginScreen(
        onLogin: () {
          isLoggedIn = true;
          notifyListeners();
        },
        onRegister: () {
          isRegister = true;
          notifyListeners();
        },
      ),
    ),
    if (isRegister == true)
      MaterialPage(
        child: RegisterScreen(
          onRegister: () {
            isRegister = false;
            notifyListeners();
          },
          onLogin: () {
            isRegister = false;
            notifyListeners();
          },
        ),
      ),
  ];

  List<Page> get _loggedInStack => [
    MaterialPage(
      key: const ValueKey("HomeScreen"),
      child: HomeScreen(
        onLogout: () {
          isLoggedIn = false;
          notifyListeners();
        },
        onDetail: (String id) {
          selectedStory = id;
          notifyListeners();
        },
        onAddStory: () {
          isAddStory = true;
          notifyListeners();
        },
      ),
    ),
    if (selectedStory != null)
      MaterialPage(
        key: ValueKey("DetailStoryScreen-$selectedStory"),
        child: DetailScreen(storyId: selectedStory!),
      ),
    if (isAddStory == true)
      MaterialPage(
        key: ValueKey("AddStoryScreen"),
        child: AddStoryScreen(
          onPost: () {
            isAddStory = false;
            notifyListeners();
          },
        ),
      ),
  ];
}
