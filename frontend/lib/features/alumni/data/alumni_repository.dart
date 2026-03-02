import 'alumni_remote_data_source.dart';

class AlumniRepository {
  final AlumniRemoteDataSource remoteDataSource;

  AlumniRepository({required this.remoteDataSource});

  Future<List<Map<String, dynamic>>> getAlumni() async {
    return await remoteDataSource.getAlumni();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await remoteDataSource.updateProfile(data);
  }
}
