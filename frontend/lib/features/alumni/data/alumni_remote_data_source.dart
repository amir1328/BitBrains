import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class AlumniRemoteDataSource {
  final ApiClient apiClient;

  AlumniRemoteDataSource({required this.apiClient});

  Future<List<Map<String, dynamic>>> getAlumni() async {
    try {
      final response = await apiClient.dio.get('/alumni/');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load alumni');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/alumni/profile', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update profile');
    }
  }

  Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      final response = await apiClient.dio.get('/alumni/jobs');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load jobs');
    }
  }

  Future<void> createJob(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/alumni/jobs', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to post job');
    }
  }
}
