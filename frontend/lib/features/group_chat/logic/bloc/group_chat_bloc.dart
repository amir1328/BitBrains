import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/network/api_client.dart'; // To fetch history
import 'group_chat_event.dart';
import 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final WebSocketService _webSocketService;
  final ApiClient _apiClient;
  StreamSubscription? _messageSubscription;

  GroupChatBloc({
    required WebSocketService webSocketService,
    required ApiClient apiClient,
  }) : _webSocketService = webSocketService,
       _apiClient = apiClient,
       super(GroupChatInitial()) {
    on<ConnectGroupChat>(_onConnect);
    on<DisconnectGroupChat>(_onDisconnect);
    on<SendGroupMessage>(_onSendMessage);
    on<ReceiveGroupMessage>(_onReceiveMessage);
    on<LoadGroupChatHistory>(_onLoadHistory);
  }

  Future<void> _onConnect(
    ConnectGroupChat event,
    Emitter<GroupChatState> emit,
  ) async {
    // 1. Connect WebSocket
    // Use the base URL from the API Client (which handles platform logic)
    final baseUrl = _apiClient.dio.options.baseUrl;

    _webSocketService.connect(baseUrl, event.roomId, event.userId);

    // 2. Listen to stream
    _messageSubscription?.cancel();
    _messageSubscription = _webSocketService.messageStream.listen((message) {
      add(ReceiveGroupMessage(message));
    });

    // 3. Load History
    add(LoadGroupChatHistory(event.roomId));
  }

  Future<void> _onLoadHistory(
    LoadGroupChatHistory event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        '/ws/chat/history/${event.roomId}',
      );
      final List<dynamic> data = response.data;
      // Convert to List<Map>
      final messages = data.map((e) => e as Map<String, dynamic>).toList();
      emit(GroupChatConnected(messages: messages));
    } catch (e) {
      // If fetch fails, we can still be connected, just no history
      // Or emit error
      print("Failed to load history: $e");
      // Initialize with empty if not already connected state
      if (state is! GroupChatConnected) {
        emit(const GroupChatConnected(messages: []));
      }
    }
  }

  Future<void> _onDisconnect(
    DisconnectGroupChat event,
    Emitter<GroupChatState> emit,
  ) async {
    _webSocketService.disconnect();
    _messageSubscription?.cancel();
    emit(GroupChatInitial());
  }

  Future<void> _onSendMessage(
    SendGroupMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    _webSocketService.sendMessage(event.content);
    // Optimistic update?
    // Wait for echo back usually better for consistency, or append purely local "pending" message
  }

  Future<void> _onReceiveMessage(
    ReceiveGroupMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    if (state is GroupChatConnected) {
      final currentMessages = List<Map<String, dynamic>>.from(
        (state as GroupChatConnected).messages,
      );
      currentMessages.add(event.message);
      emit((state as GroupChatConnected).copyWith(messages: currentMessages));
    }
  }

  @override
  Future<void> close() {
    _webSocketService.disconnect();
    _messageSubscription?.cancel();
    return super.close();
  }
}
