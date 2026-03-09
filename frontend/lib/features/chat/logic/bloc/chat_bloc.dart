import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/chat_repository.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final List<Map<String, String>> _messages = [];

  static const String _kChatHistoryKey = 'chat_messages_history';

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<ChatQuestionAsked>(_onChatQuestionAsked);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<ClearChatHistory>(_onClearChatHistory);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString(_kChatHistoryKey);
      if (historyStr != null && historyStr.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(historyStr);
        _messages.clear();
        for (var item in decodedList) {
          _messages.add(Map<String, String>.from(item));
        }
        emit(ChatLoaded(messages: List.from(_messages)));
      }
    } catch (e) {
      // Ignore load errors and start fresh
      print('Failed to load chat history: $e');
    }
  }

  Future<void> _onClearChatHistory(
    ClearChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    _messages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kChatHistoryKey);
    emit(ChatLoaded(messages: []));
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = json.encode(_messages);
      await prefs.setString(_kChatHistoryKey, encodedList);
    } catch (e) {
      print('Failed to save chat history: $e');
    }
  }

  Future<void> _onChatQuestionAsked(
    ChatQuestionAsked event,
    Emitter<ChatState> emit,
  ) async {
    // Optimistic update
    _messages.add({'role': 'user', 'text': event.question});
    await _saveHistory();
    emit(ChatLoaded(messages: List.from(_messages)));

    try {
      // Extract history to pass to the backend (exclude the very last optimistic message)
      final historyToPass = _messages.length > 1
          ? _messages
                .sublist(0, _messages.length - 1)
                .map(
                  (m) => {
                    'role': m['role'] == 'ai'
                        ? 'assistant'
                        : m['role'] ?? 'user',
                    'content': m['text'] ?? '',
                  },
                )
                .toList()
          : <Map<String, dynamic>>[];

      final answer = await repository.askQuestion(
        event.question,
        history: historyToPass,
      );
      _messages.add({
        'role': 'assistant',
        'text': answer,
      }); // Save 'assistant' internally or 'ai'
      await _saveHistory();
      emit(ChatLoaded(messages: List.from(_messages)));
    } catch (e) {
      // Re-emit loaded state to show previous history on error
      emit(ChatError(e.toString()));
      emit(ChatLoaded(messages: List.from(_messages)));
    }
  }
}
