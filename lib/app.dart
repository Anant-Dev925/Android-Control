import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/core/theme/app_theme.dart';
import 'package:android_control/core/theme/theme_cubit.dart';
import 'package:android_control/core/di/service_locator.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';
import 'package:android_control/presentation/cubit/session_cubit.dart';
import 'package:android_control/presentation/pages/chat_page.dart';
import 'package:android_control/data/models/connection_state_model.dart' as conn;

class AndroidControlApp extends StatelessWidget {
  const AndroidControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<ConnectionCubit>(
          create: (_) => sl<ConnectionCubit>()..initialize(),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => sl<ChatCubit>(),
        ),
        BlocProvider<SessionCubit>(
          create: (_) => sl<SessionCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Android AI Control',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.flutterThemeMode,
            home: const ChatPage(),
          );
        },
      ),
    );
  }
}
