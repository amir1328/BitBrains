import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

class ApiClient {
  final Dio _dio;
  // A separate Dio instance for token refresh — avoids interceptor loops
  final Dio _refreshDio;

  ApiClient() : _dio = Dio(_baseOptions()), _refreshDio = Dio(_baseOptions()) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Attach access token to every request
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_kAccessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // On 401 → try refreshing, then retry the original request once
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString(_kRefreshToken);

            if (refreshToken != null) {
              try {
                // Call refresh endpoint
                final refreshResponse = await _refreshDio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                final newAccess = refreshResponse.data['access_token'];
                final newRefresh = refreshResponse.data['refresh_token'];

                // Save new tokens
                await prefs.setString(_kAccessToken, newAccess);
                if (newRefresh != null) {
                  await prefs.setString(_kRefreshToken, newRefresh);
                }

                // Retry the original request with the new token
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newAccess';
                final retryResponse = await _dio.fetch(retryOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                // Refresh failed → clear tokens (user must re-login)
                await prefs.remove(_kAccessToken);
                await prefs.remove(_kRefreshToken);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: () {
    if (kIsWeb) {
      debugPrint('ApiClient: Running on Web, using 127.0.0.1');
      return 'http://127.0.0.1:8000';
    } else {
      debugPrint('ApiClient: Running on Mobile, using 10.0.2.2');
      return 'http://10.0.2.2:8000';
    }
  }(),
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
  headers: {'Content-Type': 'application/json'},
);
