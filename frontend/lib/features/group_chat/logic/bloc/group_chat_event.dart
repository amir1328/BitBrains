import 'package:equatable/equatable.dart';

abstract class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  @override
  List<Object> get props => [];
}

class ConnectGroupChat extends GroupChatEvent {
  final String roomId;
  final int userId;

  const ConnectGroupChat({required this.roomId, required this.userId});

  @override
  List<Object> get props => [roomId, userId];
}

class DisconnectGroupChat extends GroupChatEvent {}

class SendGroupMessage extends GroupChatEvent {
  final String content;

  const SendGroupMessage(this.content);

  @override
  List<Object> get props => [content];
}

class ReceiveGroupMessage extends GroupChatEvent {
  final Map<String, dynamic> message;

  const ReceiveGroupMessage(this.message);

  @override
  List<Object> get props => [message];
}

class LoadGroupChatHistory extends GroupChatEvent {
  final String roomId;
  const LoadGroupChatHistory(this.roomId);

  @override
  List<Object> get props => [roomId];
}
