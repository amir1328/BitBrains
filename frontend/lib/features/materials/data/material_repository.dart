import 'material_remote_data_source.dart';

class MaterialRepository {
  final MaterialRemoteDataSource remoteDataSource;

  MaterialRepository({required this.remoteDataSource});

  Future<List<Map<String, dynamic>>> getMaterials({
    String? courseName,
    int? semester,
  }) async {
    try {
      final data = await remoteDataSource.getMaterials(courseName, semester);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to fetch materials: $e');
    }
  }
}
