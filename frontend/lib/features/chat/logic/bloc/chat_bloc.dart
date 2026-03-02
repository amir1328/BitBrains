import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/chat_repository.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final List<Map<String, String>> _messages = [];

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<ChatQuestionAsked>(_onChatQuestionAsked);
  }

  Future<void> _onChatQuestionAsked(
    ChatQuestionAsked event,
    Emitter<ChatState> emit,
  ) async {
    // Optimistic update
    _messages.add({'role': 'user', 'text': event.question});
    emit(ChatLoaded(messages: List.from(_messages))); // Emit immediately

    // Show loading indicator? Maybe not whole screen, just a typing indicator.
    // For simplicity, we just wait. Or we could add a dummy "typing..." message.

    try {
      final answer = await repository.askQuestion(event.question);
      _messages.add({'role': 'ai', 'text': answer});
      emit(ChatLoaded(messages: List.from(_messages)));
    } catch (e) {
      // Remove user message on failure? Or just show error?
      // _messages.removeLast();
      emit(ChatError(e.toString()));
      // Re-emit loaded state to show previous history
      emit(ChatLoaded(messages: List.from(_messages)));
    }
  }
}
