import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';
import 'auth_remote_data_source.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kCachedUser = 'cached_user'; // ← new: stores user JSON

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  /// Login: saves tokens + registers FCM token
  Future<void> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccessToken, response['access_token']);
      if (response['refresh_token'] != null) {
        await prefs.setString(_kRefreshToken, response['refresh_token']);
      }
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

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kCachedUser); // ← clear cached user on logout
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

  // ── User cache helpers ────────────────────────────────────────────────────

  /// Returns the cached user map instantly (no network), or null if none.
  Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCachedUser);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  /// Persists the user map locally so future app starts are instant.
  Future<void> saveUserCache(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCachedUser, jsonEncode(user));
  }

  // ── Token refresh ─────────────────────────────────────────────────────────

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

  void _registerFcmToken() async {
    try {
      final token = await NotificationService().getToken();
      if (token != null) {
        await remoteDataSource.updateFcmToken(token);
      }
    } catch (e) {
      // Non-blocking
    }
  }
}
