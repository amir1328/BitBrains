import 'profile_remote_data_source.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> getProfile() async {
    return await remoteDataSource.getUserProfile();
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await remoteDataSource.updateUserProfile(data);
  }
}
