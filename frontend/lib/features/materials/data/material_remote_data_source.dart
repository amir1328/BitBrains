import 'package:dio/dio.dart';
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

  Future<Map<String, dynamic>> uploadMaterial({
    required String title,
    required String courseName,
    required int semester,
    String? description,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'course_name': courseName,
      'semester': semester,
      if (description != null && description.isNotEmpty)
        'description': description,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await apiClient.dio.post(
      '/materials/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data as Map<String, dynamic>;
  }
}
