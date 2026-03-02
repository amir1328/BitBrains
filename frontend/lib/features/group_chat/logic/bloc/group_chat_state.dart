import 'package:equatable/equatable.dart';

abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupChatConnected extends GroupChatState {
  final List<Map<String, dynamic>> messages;

  const GroupChatConnected({this.messages = const []});

  GroupChatConnected copyWith({List<Map<String, dynamic>>? messages}) {
    return GroupChatConnected(messages: messages ?? this.messages);
  }

  @override
  List<Object> get props => [messages];
}

class GroupChatError extends GroupChatState {
  final String message;
  const GroupChatError(this.message);

  @override
  List<Object> get props => [message];
}
