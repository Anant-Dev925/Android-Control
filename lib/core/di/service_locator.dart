import 'package:get_it/get_it.dart';
import 'package:android_control/data/services/api_service.dart';
import 'package:android_control/data/services/socket_service.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // Cubits
  sl.registerFactory<ConnectionCubit>(
    () => ConnectionCubit(
      apiService: sl<ApiService>(),
      socketService: sl<SocketService>(),
    ),
  );

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(apiService: sl<ApiService>()),
  );
}
