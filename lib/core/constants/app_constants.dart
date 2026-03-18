class AppConstants {
  static const String appName = 'Android AI Control';
  static const String serverUrl = 'http://100.85.62.80:3000';
  static const String wsUrl = 'ws://100.85.62.80:3000';
  
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 180);
  static const Duration pingInterval = Duration(seconds: 25);
  static const Duration pingTimeout = Duration(seconds: 20);
  
  static const int maxReconnectionAttempts = 5;
  static const Duration reconnectionDelay = Duration(seconds: 1);
}
