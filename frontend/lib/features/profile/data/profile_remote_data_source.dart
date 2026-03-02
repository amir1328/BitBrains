import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
// Reusing AuthUser model if suitable or create ProfileModel

class ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await apiClient.dio.get('/users/me');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.dio.put('/users/me', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update profile');
    }
  }
}
