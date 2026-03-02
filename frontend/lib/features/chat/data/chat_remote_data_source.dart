import '../../../core/network/api_client.dart';

class ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> askQuestion(String question) async {
    try {
      final response = await apiClient.dio.post(
        '/chat/ask',
        data: {'question': question},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
