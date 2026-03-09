import 'chat_remote_data_source.dart';

class ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepository({required this.remoteDataSource});

  Future<String> askQuestion(
    String question, {
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final response = await remoteDataSource.askQuestion(
        question,
        history: history,
      );
      return response['answer'] ?? "No answer returned.";
    } catch (e) {
      throw Exception('Failed to get answer: $e');
    }
  }
}
