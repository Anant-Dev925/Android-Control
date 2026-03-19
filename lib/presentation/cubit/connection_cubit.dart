import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/data/models/connection_state_model.dart';
import 'package:android_control/data/services/api_service.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  final ApiService _apiService;
  Timer? _checkTimer;

  ConnectionCubit({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(const ConnectionState());

  Future<void> initialize() async {
    emit(state.copyWith(
      serverStatus: ConnectionStatus.connecting,
      serverMessage: 'Connecting...',
    ));

    await checkConnection();
    
    // Check connection every 10 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkConnection();
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
    _checkTimer?.cancel();
    return super.close();
  }
}
