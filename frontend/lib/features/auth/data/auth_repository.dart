import 'package:shared_preferences/shared_preferences.dart';
import 'auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  Future<void> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final token = response['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await remoteDataSource.register(userData);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}
