import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: userData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
