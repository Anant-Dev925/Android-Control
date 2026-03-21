import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:android_control/core/constants/app_constants.dart';

class SocketService {
  io.Socket? _socket;
  
  final StreamController<bool> _serverStatusController = StreamController<bool>.broadcast();
  final StreamController<bool> _androidStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get serverStatusStream => _serverStatusController.stream;
  Stream<bool> get androidStatusStream => _androidStatusController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  bool _isAndroidConnected = false;
  bool get isAndroidConnected => _isAndroidConnected;
  
  void connect() {
    _socket = io.io(
      AppConstants.wsUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );
    
    _socket!.onConnect((_) {
      _isConnected = true;
      _serverStatusController.add(true);
      _socket!.emit('status');
    });
    
    _socket!.onDisconnect((_) {
      _isConnected = false;
      _serverStatusController.add(false);
    });
    
    _socket!.onConnectError((error) {
      _isConnected = false;
      _serverStatusController.add(false);
    });
    
    _socket!.on('status', (data) {
      if (data is Map) {
        _isAndroidConnected = data['connected'] == true;
        _androidStatusController.add(_isAndroidConnected);
      }
    });
    
    _socket!.on('heartbeat', (data) {
      if (data is Map) {
        _isAndroidConnected = data['connected'] == true;
        _androidStatusController.add(_isAndroidConnected);
      }
    });
    
    _socket!.on('connected', (data) {
      _isConnected = true;
      _serverStatusController.add(true);
    });
    
    _socket!.on('pong', (data) {
      _isConnected = true;
      _serverStatusController.add(true);
    });
  }
  
  void requestStatus() {
    if (_isConnected) {
      _socket!.emit('status');
    }
  }
  
  void reconnect() {
    _socket?.disconnect();
    _socket?.connect();
  }
  
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
  
  void dispose() {
    disconnect();
    _serverStatusController.close();
    _androidStatusController.close();
  }
}
