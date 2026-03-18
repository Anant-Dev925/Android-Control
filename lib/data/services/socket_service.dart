import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:android_control/core/constants/app_constants.dart';

class SocketService {
  WebSocketChannel? _channel;
  final _connectionController = StreamController<bool>.broadcast();
  final _androidStatusController = StreamController<bool>.broadcast();
  final _heartbeatController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  int _reconnectAttempts = 0;

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<bool> get androidStatusStream => _androidStatusController.stream;
  Stream<Map<String, dynamic>> get heartbeatStream => _heartbeatController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isConnected => _isConnected;

  void connect() {
    _connect();
  }

  void _connect() {
    try {
      final uri = Uri.parse(AppConstants.wsUrl);
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) => _handleMessage(data),
        onError: (error) {
          _errorController.add('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      ).onDone(() {
        _handleDisconnect();
      });

      _isConnected = true;
      _connectionController.add(true);
      _reconnectAttempts = 0;
      _startHeartbeat();
    } catch (e) {
      _errorController.add('Connection failed: $e');
      _handleDisconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final message = json.decode(data as String) as Map<String, dynamic>;
      final type = message['type'] ?? message['event'] ?? 'unknown';

      switch (type) {
        case 'connected':
          _messageController.add({'type': 'connected', 'data': message});
          break;
        case 'disconnected':
          _messageController.add({'type': 'disconnected', 'data': message});
          break;
        case 'status':
          if (message['connected'] != null) {
            _androidStatusController.add(message['connected'] as bool);
          }
          break;
        case 'heartbeat':
          _heartbeatController.add(message);
          break;
        default:
          if (message['connected'] != null) {
            _androidStatusController.add(message['connected'] as bool);
          }
          _heartbeatController.add(message);
      }
    } catch (e) {
      // Raw message received
      if (data is String && data.contains('connected')) {
        _connectionController.add(true);
      }
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectionController.add(false);
    _stopHeartbeat();
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      sendPing();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= AppConstants.maxReconnectionAttempts) {
      _errorController.add('Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(AppConstants.reconnectionDelay, () {
      _reconnectAttempts++;
      _connect();
    });
  }

  void sendChat(String message, {Function(Map<String, dynamic>)? callback}) {
    if (_channel == null || !_isConnected) {
      callback?.call({'error': 'Not connected'});
      return;
    }

    final data = json.encode({
      'event': 'chat',
      'data': {'message': message},
    });
    _channel!.sink.add(data);
  }

  void sendExecute(Map<String, dynamic> data, {Function(Map<String, dynamic>)? callback}) {
    if (_channel == null || !_isConnected) {
      callback?.call({'error': 'Not connected'});
      return;
    }

    _channel!.sink.add(json.encode({
      'event': 'execute',
      'data': data,
    }));
  }

  void requestStatus({Function(Map<String, dynamic>)? callback}) {
    if (_channel == null || !_isConnected) {
      callback?.call({'error': 'Not connected'});
      return;
    }

    _channel!.sink.add(json.encode({
      'event': 'status',
      'data': {},
    }));
  }

  void requestReconnect({Function(Map<String, dynamic>)? callback}) {
    if (_channel == null || !_isConnected) {
      callback?.call({'error': 'Not connected'});
      return;
    }

    _channel!.sink.add(json.encode({
      'event': 'reconnect',
      'data': {},
    }));
  }

  void sendPing() {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(json.encode({'event': 'ping', 'data': {}}));
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _connectionController.close();
    _androidStatusController.close();
    _heartbeatController.close();
    _messageController.close();
    _errorController.close();
  }
}
