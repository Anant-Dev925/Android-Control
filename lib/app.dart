import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/core/theme/app_theme.dart';
import 'package:android_control/core/di/service_locator.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';
import 'package:android_control/presentation/cubit/session_cubit.dart';
import 'package:android_control/presentation/pages/chat_page.dart';

class AndroidControlApp extends StatelessWidget {
  const AndroidControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
      child: MaterialApp(
        title: 'Android AI Control',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const ChatPage(),
      ),
    );
  }
}
