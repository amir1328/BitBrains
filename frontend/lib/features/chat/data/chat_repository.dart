import 'chat_remote_data_source.dart';

class ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepository({required this.remoteDataSource});

  Future<String> askQuestion(String question) async {
    try {
      final response = await remoteDataSource.askQuestion(question);
      return response['answer'] ?? "No answer returned.";
    } catch (e) {
      throw Exception('Failed to get answer: $e');
    }
  }
}
