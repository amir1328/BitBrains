import '../../../core/network/api_client.dart';

class ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> askQuestion(
    String question, {
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/chat/ask',
        data: {'question': question, if (history != null) 'history': history},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
