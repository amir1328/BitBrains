import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatQuestionAsked extends ChatEvent {
  final String question;
  ChatQuestionAsked(this.question);
}

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

// We might want to keep history, so a list of messages is better
class ChatLoaded extends ChatState {
  final List<Map<String, String>>
  messages; // [{'role': 'user', 'text': '...'}, {'role': 'ai', 'text': '...'}]

  ChatLoaded({this.messages = const []});

  @override
  List<Object> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
