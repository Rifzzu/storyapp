import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storyapp/data/db/auth_repository.dart';
import 'package:storyapp/screen/add_story/add_story_screen.dart';
import 'package:storyapp/screen/add_story/maps_on_pick_screen.dart';
import 'package:storyapp/screen/detail/detail_map_screen.dart';
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
  LatLng? latLng;
  bool isLocationFromMap = false;
  LatLng? locationLatLng;

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
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        if (route.settings is MaterialPage) {
          final pageKey = (route.settings as MaterialPage).key;
          if (pageKey == ValueKey("DetailMapScreen-$latLng")) {
            latLng = null;
          } else if (pageKey == ValueKey("DetailStoryScreen-$selectedStory")) {
            selectedStory = null;
          } else if (pageKey == const ValueKey("AddStoryScreen")) {
            isAddStory = false;
          } else if (pageKey == const ValueKey("RegisterScreen")) {
            isRegister = false;
          } else if (pageKey == ValueKey("MapsOnPickScreen-$locationLatLng")) {
            isLocationFromMap = false;
          }
        }
        notifyListeners();
        return true;
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
        key: const ValueKey("RegisterScreen"),
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
        child: DetailScreen(
          storyId: selectedStory!,
          toStoryMap: (latLng) {
            this.latLng = latLng;
            notifyListeners();
          },
        ),
      ),
    if (isAddStory == true)
      MaterialPage(
        key: ValueKey("AddStoryScreen"),
        child: AddStoryScreen(
          onPost: () {
            isAddStory = false;
            notifyListeners();
          },
          onChooseLocation: (latLng) {
            isLocationFromMap = true;
            locationLatLng = latLng;
            notifyListeners();
          },
        ),
      ),
    if (latLng != null)
      MaterialPage(
        key: ValueKey("DetailMapScreen-$latLng"),
        child: DetailMapScreen(latLng: latLng!),
      ),
    if (isLocationFromMap)
      MaterialPage(
        key: ValueKey("MapsOnPickScreen-$locationLatLng"),
        child: MapsOnPickScreen(
          latLng: locationLatLng,
          onChooseMap: (LatLng latLng) {
            isLocationFromMap = false;
            notifyListeners();
          },
        ),
      ),
  ];
}
