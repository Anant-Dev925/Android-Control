import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/data/models/connection_state_model.dart';
import 'package:android_control/data/services/api_service.dart';
import 'package:android_control/data/services/socket_service.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  final ApiService _apiService;
  final SocketService _socketService;
  
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _androidStatusSubscription;
  StreamSubscription? _heartbeatSubscription;

  ConnectionCubit({
    required ApiService apiService,
    required SocketService socketService,
  })  : _apiService = apiService,
        _socketService = socketService,
        super(const ConnectionState());

  Future<void> initialize() async {
    emit(state.copyWith(
      serverStatus: ConnectionStatus.connecting,
      serverMessage: 'Connecting...',
    ));

    _setupListeners();
    _socketService.connect();
    
    await checkConnection();
  }

  void _setupListeners() {
    _connectionSubscription = _socketService.connectionStream.listen((connected) {
      emit(state.copyWith(
        serverStatus: connected ? ConnectionStatus.connected : ConnectionStatus.disconnected,
        serverMessage: connected ? 'Connected' : 'Disconnected',
      ));
    });

    _androidStatusSubscription = _socketService.androidStatusStream.listen((connected) {
      emit(state.copyWith(
        androidStatus: connected ? ConnectionStatus.connected : ConnectionStatus.disconnected,
        androidMessage: connected ? 'Android connected' : 'Android disconnected',
      ));
    });

    _heartbeatSubscription = _socketService.heartbeatStream.listen((data) {
      emit(state.copyWith(
        androidStatus: data['connected'] == true 
            ? ConnectionStatus.connected 
            : ConnectionStatus.disconnected,
        lastHeartbeat: DateTime.now(),
      ));
    });
  }

  Future<void> checkConnection() async {
    final response = await _apiService.getStatus();
    
    if (response.success && response.data != null) {
      emit(state.copyWith(
        serverStatus: ConnectionStatus.connected,
        serverMessage: 'Server connected',
        androidStatus: response.data!['connected'] == true 
            ? ConnectionStatus.connected 
            : ConnectionStatus.disconnected,
        androidMessage: response.data!['connected'] == true 
            ? 'Android connected' 
            : 'Android not connected',
      ));
    } else {
      emit(state.copyWith(
        serverStatus: ConnectionStatus.error,
        serverMessage: response.error ?? 'Failed to connect',
      ));
    }
  }

  Future<void> reconnect() async {
    emit(state.copyWith(
      serverStatus: ConnectionStatus.connecting,
      serverMessage: 'Reconnecting...',
    ));

    _socketService.disconnect();
    _socketService.connect();
    
    await checkConnection();
  }

  Future<void> reconnectAndroid() async {
    emit(state.copyWith(
      androidStatus: ConnectionStatus.connecting,
      androidMessage: 'Reconnecting to Android...',
    ));

    final response = await _apiService.reconnect();
    
    if (response.success && response.data?['success'] == true) {
      await Future.delayed(const Duration(seconds: 2));
      await checkConnection();
    } else {
      emit(state.copyWith(
        androidStatus: ConnectionStatus.error,
        androidMessage: response.error ?? 'Failed to reconnect',
      ));
    }
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    _androidStatusSubscription?.cancel();
    _heartbeatSubscription?.cancel();
    return super.close();
  }
}
