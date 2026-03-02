import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect(String baseUrl, String roomId, int userId) {
    if (_isConnected) return;

    // Convert http/https to ws/wss
    final wsUrl = baseUrl.replaceFirst('http', 'ws');
    final url = '$wsUrl/ws/chat/$roomId/$userId';

    debugPrint("Connecting to WebSocket: $url");

    try {
      // Use WebSocketChannel.connect for cross-platform support (Web & Mobile)
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          debugPrint("Received: $message");
          try {
            final data = jsonDecode(message);
            _messageController.add(data);
          } catch (e) {
            debugPrint("Error decoding message: $e");
          }
        },
        onDone: () {
          debugPrint("WebSocket Closed");
          _isConnected = false;
        },
        onError: (error) {
          debugPrint("WebSocket Error: $error");
          _isConnected = false;
        },
      );
    } catch (e) {
      debugPrint("WebSocket Connection Failed: $e");
      _isConnected = false;
    }
  }

  void sendMessage(String content) {
    if (_channel != null && _isConnected) {
      final message = jsonEncode({"content": content});
      _channel!.sink.add(message);
    } else {
      debugPrint("Cannot send message: WebSocket not connected");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _isConnected = false;
    }
  }
}
