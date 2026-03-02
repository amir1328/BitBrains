import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class AchievementRemoteDataSource {
  final ApiClient apiClient;

  AchievementRemoteDataSource({required this.apiClient});

  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response = await apiClient.dio.get('/achievements/');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to load achievements',
      );
    }
  }

  Future<Map<String, dynamic>> createAchievement(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.dio.post('/achievements/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to create achievement',
      );
    }
  }
}
