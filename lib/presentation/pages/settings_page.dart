import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/core/theme/theme_cubit.dart';
import 'package:android_control/core/constants/app_constants.dart';
import 'package:android_control/presentation/pages/about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            children: [
              _buildSection(
                context,
                'Appearance',
                [
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Theme'),
                    subtitle: Text(_getThemeModeName(state.themeMode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(context, state.themeMode),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.code),
                    title: const Text('Syntax Highlighting'),
                    subtitle: const Text('Show code with colors'),
                    value: state.showSyntaxHighlighting,
                    onChanged: (_) => context.read<ThemeCubit>().toggleSyntaxHighlighting(),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Chat',
                [
                  SwitchListTile(
                    secondary: const Icon(Icons.vertical_align_bottom),
                    title: const Text('Auto Scroll'),
                    subtitle: const Text('Scroll to new messages'),
                    value: state.autoScroll,
                    onChanged: (_) => context.read<ThemeCubit>().toggleAutoScroll(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Context Limit'),
                    subtitle: Text('${state.contextLimit} messages sent to AI'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showContextLimitDialog(context, state.contextLimit),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Connection',
                [
                  ListTile(
                    leading: const Icon(Icons.computer),
                    title: const Text('Server URL'),
                    subtitle: Text(AppConstants.serverUrl),
                    trailing: const Icon(Icons.copy),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Server URL copied')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cable),
                    title: const Text('WebSocket URL'),
                    subtitle: Text(AppConstants.wsUrl),
                    trailing: const Icon(Icons.copy),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('WebSocket URL copied')),
                      );
                    },
                  ),
                ],
              ),
              _buildSection(
                context,
                'About',
                [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About App'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  String _getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, AppThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeModeName(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeCubit>().setThemeMode(value);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showContextLimitDialog(BuildContext context, int currentLimit) {
    final limits = [10, 15, 20, 30, 50];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Context Limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: limits.map((limit) {
            return RadioListTile<int>(
              title: Text('$limit messages'),
              subtitle: Text('AI will remember last $limit messages'),
              value: limit,
              groupValue: currentLimit,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeCubit>().setContextLimit(value);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
