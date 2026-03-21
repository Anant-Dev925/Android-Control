import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/data/models/connection_state_model.dart';
import 'package:android_control/data/services/api_service.dart';
import 'package:android_control/data/services/socket_service.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  final ApiService _apiService;
  final SocketService _socketService;
  Timer? _fallbackTimer;
  StreamSubscription<bool>? _serverSubscription;
  StreamSubscription<bool>? _androidSubscription;

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

    _setupSocketListeners();

    await checkConnection();
    
    _startFallbackCheck();
  }

  void _setupSocketListeners() {
    _serverSubscription = _socketService.serverStatusStream.listen((connected) {
      if (connected) {
        emit(state.copyWith(
          serverStatus: ConnectionStatus.connected,
          serverMessage: 'Server connected',
        ));
        _socketService.requestStatus();
      } else {
        emit(state.copyWith(
          serverStatus: ConnectionStatus.disconnected,
          serverMessage: 'Server disconnected',
        ));
      }
    });

    _androidSubscription = _socketService.androidStatusStream.listen((connected) {
      emit(state.copyWith(
        androidStatus: connected ? ConnectionStatus.connected : ConnectionStatus.disconnected,
        androidMessage: connected ? 'Android connected' : 'Android not connected',
      ));
    });

    _socketService.connect();
  }

  void _startFallbackCheck() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_socketService.isConnected) {
        checkConnection();
      }
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
    _socketService.reconnect();
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
    _fallbackTimer?.cancel();
    _serverSubscription?.cancel();
    _androidSubscription?.cancel();
    _socketService.dispose();
    return super.close();
  }
}
