import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyapp/data/api/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', token);
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    await preferences.remove('token');
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await apiService.register(
      name: name,
      email: email,
      password: password,
    );
    return result;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await apiService.login(email: email, password: password);
    if (!result['error']) {
      final token = result['loginResult']['token'];
      await saveToken(token);
    }
    return result;
  }
}
