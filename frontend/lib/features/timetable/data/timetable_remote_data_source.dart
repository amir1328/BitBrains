import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import 'timetable_model.dart';

class TimetableRemoteDataSource {
  final ApiClient apiClient;

  TimetableRemoteDataSource({required this.apiClient});

  Future<List<TimetableEntry>> getTimetable(
    int semester,
    String courseName,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/timetable/',
        queryParameters: {'semester': semester, 'course_name': courseName},
      );

      return (response.data as List)
          .map((e) => TimetableEntry.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load timetable');
    }
  }

  Future<void> createTimetableEntry(Map<String, dynamic> entry) async {
    try {
      await apiClient.dio.post('/timetable/', data: entry);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create entry');
    }
  }

  Future<void> deleteTimetableEntry(int id) async {
    try {
      await apiClient.dio.delete('/timetable/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete entry');
    }
  }
}
