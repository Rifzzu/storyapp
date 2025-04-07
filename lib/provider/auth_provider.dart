import 'package:flutter/material.dart';
import 'package:storyapp/data/db/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider(this.authRepository);

  bool isLoggedIn = false;
  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  String? message;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoadingRegister = true;
    message = null;
    notifyListeners();

    try {
      final result = await authRepository.register(
        name: name,
        email: email,
        password: password,
      );

      if (!result['error']) {
        message = "Registration successful";
      } else {
        message = result['message'];
      }

      return result;
    } catch (e) {
      message = "An error occurred: ${e.toString()}";
      return {'error': true, 'message': message};
    } finally {
      isLoadingRegister = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    isLoadingLogin = true;
    message = null;
    notifyListeners();

    try {
      final result = await authRepository.login(
        email: email,
        password: password,
      );

      if (!result['error']) {
        isLoggedIn = true;
        message = "Login successful";
      } else {
        isLoggedIn = false;
        message = result['message'];
      }
    } catch (e) {
      isLoggedIn = false;
      message = "An error occurred: ${e.toString()}";
    }

    isLoadingLogin = false;
    notifyListeners();
    return isLoggedIn;
  }

  Future<bool> logout() async {
    isLoadingLogout = true;
    message = null;
    notifyListeners();

    bool success = false;

    try {
      await authRepository.logout();
      isLoggedIn = await authRepository.isLoggedIn();
      if (!isLoggedIn) {
        message = "Logout successful";
        success = true;
      } else {
        message = "Logout failed";
      }
    } catch (e) {
      message = "An error occurred during logout: ${e.toString()}";
    }

    isLoadingLogout = false;
    notifyListeners();

    return success;
  }
}
