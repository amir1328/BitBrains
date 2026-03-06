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
    debugPrint('ApiClient initialized with BaseURL: ${_dio.options.baseUrl}');
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Attach access token to every request
        onRequest: (options, handler) async {
          debugPrint('DIO REQUEST: [${options.method}] ${options.uri}');
          debugPrint('DIO HEADERS: ${options.headers}');

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_kAccessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint(
            'DIO RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },

        // On 401 → try refreshing, then retry the original request once
        onError: (DioException error, handler) async {
          debugPrint(
            'DIO ERROR: [${error.response?.statusCode}] ${error.type} - ${error.message}',
          );
          debugPrint('DIO ERROR DATA: ${error.response?.data}');

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
    // Current target for cloud testing
    const productionUrl = 'https://bitbrains-production.up.railway.app';

    if (kReleaseMode) {
      return productionUrl;
    }

    // For Debug mode, use Railway so we can test cloud integration immediately
    return productionUrl;

    /* 
    // Fallback for local development (Emulator / Web) if needed:
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
    */
  }(),
  connectTimeout: const Duration(
    seconds: 15,
  ), // Increased for cloud cold-starts
  receiveTimeout: const Duration(seconds: 60),
  headers: {'Content-Type': 'application/json'},
);
