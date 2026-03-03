import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';
import 'auth_remote_data_source.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  /// Login: saves both access and refresh tokens, then registers FCM token
  Future<void> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccessToken, response['access_token']);
      if (response['refresh_token'] != null) {
        await prefs.setString(_kRefreshToken, response['refresh_token']);
      }
      // Register FCM token asynchronously (non-blocking)
      _registerFcmToken();
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
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kAccessToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefreshToken);
  }

  /// Uses the refresh token to get a new access + refresh token pair.
  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;
      final response = await remoteDataSource.refreshToken(refreshToken);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccessToken, response['access_token']);
      if (response['refresh_token'] != null) {
        await prefs.setString(_kRefreshToken, response['refresh_token']);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Gets the FCM token and registers it with the backend (fire-and-forget)
  void _registerFcmToken() async {
    try {
      final token = await NotificationService().getToken();
      if (token != null) {
        await remoteDataSource.updateFcmToken(token);
      }
    } catch (e) {
      // Non-blocking — don't fail login if FCM registration fails
    }
  }
}
