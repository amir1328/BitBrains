import 'timetable_model.dart';
import 'timetable_remote_data_source.dart';

class TimetableRepository {
  final TimetableRemoteDataSource remoteDataSource;

  TimetableRepository({required this.remoteDataSource});

  Future<List<TimetableEntry>> getTimetable({
    required int semester,
    required String courseName,
  }) async {
    return await remoteDataSource.getTimetable(semester, courseName);
  }

  Future<void> createEntry(Map<String, dynamic> entry) async {
    await remoteDataSource.createTimetableEntry(entry);
  }

  Future<void> deleteEntry(int id) async {
    await remoteDataSource.deleteTimetableEntry(id);
  }
}
