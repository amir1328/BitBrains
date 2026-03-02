import '../../../core/network/api_client.dart';

class MaterialRemoteDataSource {
  final ApiClient apiClient;

  MaterialRemoteDataSource({required this.apiClient});

  Future<List<dynamic>> getMaterials(String? courseName, int? semester) async {
    try {
      final response = await apiClient.dio.get(
        '/materials/',
        queryParameters: {
          if (courseName != null) 'course_name': courseName,
          if (semester != null) 'semester': semester,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // File upload logic will be complex due to file picking, doing simple version first
}
