import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart'; // Import for kIsWeb

class ApiClient {
  final Dio _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          // Use 127.0.0.1 for Web, 10.0.2.2 for Android Emulator
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
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] =
                'Bearer $token'; // Fixed: Added $
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
