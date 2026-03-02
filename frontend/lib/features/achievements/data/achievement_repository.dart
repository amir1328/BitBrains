import 'achievement_remote_data_source.dart';

class AchievementRepository {
  final AchievementRemoteDataSource remoteDataSource;

  AchievementRepository({required this.remoteDataSource});

  Future<List<Map<String, dynamic>>> getAchievements() async {
    return await remoteDataSource.getAchievements();
  }

  Future<void> createAchievement(Map<String, dynamic> data) async {
    await remoteDataSource.createAchievement(data);
  }
}
