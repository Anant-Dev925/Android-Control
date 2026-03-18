import 'package:equatable/equatable.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
  error,
}

class ConnectionState extends Equatable {
  final ConnectionStatus serverStatus;
  final ConnectionStatus androidStatus;
  final String? serverMessage;
  final String? androidMessage;
  final DateTime? lastHeartbeat;

  const ConnectionState({
    this.serverStatus = ConnectionStatus.disconnected,
    this.androidStatus = ConnectionStatus.disconnected,
    this.serverMessage,
    this.androidMessage,
    this.lastHeartbeat,
  });

  bool get isServerConnected => serverStatus == ConnectionStatus.connected;
  bool get isAndroidConnected => androidStatus == ConnectionStatus.connected;

  ConnectionState copyWith({
    ConnectionStatus? serverStatus,
    ConnectionStatus? androidStatus,
    String? serverMessage,
    String? androidMessage,
    DateTime? lastHeartbeat,
  }) {
    return ConnectionState(
      serverStatus: serverStatus ?? this.serverStatus,
      androidStatus: androidStatus ?? this.androidStatus,
      serverMessage: serverMessage ?? this.serverMessage,
      androidMessage: androidMessage ?? this.androidMessage,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
    );
  }

  @override
  List<Object?> get props => [
        serverStatus,
        androidStatus,
        serverMessage,
        androidMessage,
        lastHeartbeat,
      ];
}
