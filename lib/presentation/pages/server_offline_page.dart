import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/core/theme/app_theme.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';
import 'package:android_control/data/models/connection_state_model.dart' as conn;

class ServerOfflinePage extends StatelessWidget {
  const ServerOfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 100,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Server is Offline',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cannot connect to the server.\nPlease check your connections.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                BlocBuilder<ConnectionCubit, conn.ConnectionState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _StatusCard(
                          title: 'Tailscale VPN',
                          subtitle: _getStatusText(state.serverStatus),
                          icon: state.serverStatus == conn.ConnectionStatus.connected
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _getStatusColor(state.serverStatus),
                        ),
                        const SizedBox(height: 12),
                        _StatusCard(
                          title: 'ADB Connection',
                          subtitle: _getStatusText(state.androidStatus),
                          icon: state.androidStatus == conn.ConnectionStatus.connected
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _getStatusColor(state.androidStatus),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () => context.read<ConnectionCubit>().reconnect(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<ConnectionCubit, conn.ConnectionState>(
                  builder: (context, state) {
                    return Text(
                      state.serverMessage ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(conn.ConnectionStatus status) {
    switch (status) {
      case conn.ConnectionStatus.connected:
        return 'Connected';
      case conn.ConnectionStatus.connecting:
        return 'Connecting...';
      case conn.ConnectionStatus.disconnected:
        return 'Disconnected';
      case conn.ConnectionStatus.error:
        return 'Connection Error';
    }
  }

  Color _getStatusColor(conn.ConnectionStatus status) {
    switch (status) {
      case conn.ConnectionStatus.connected:
        return AppTheme.connectedColor;
      case conn.ConnectionStatus.connecting:
        return AppTheme.connectingColor;
      case conn.ConnectionStatus.disconnected:
      case conn.ConnectionStatus.error:
        return AppTheme.disconnectedColor;
    }
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
