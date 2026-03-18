import 'package:flutter/material.dart' hide ConnectionState;
import 'package:android_control/core/theme/app_theme.dart';
import 'package:android_control/data/models/connection_state_model.dart';

class ConnectionIndicator extends StatelessWidget {
  final ConnectionStatus status;
  final String label;
  final IconData connectedIcon;
  final IconData disconnectedIcon;

  const ConnectionIndicator({
    super.key,
    required this.status,
    required this.label,
    required this.connectedIcon,
    required this.disconnectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _getColor();
    final IconData icon = _getIcon();

    return Tooltip(
      message: _getTooltip(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case ConnectionStatus.connected:
        return AppTheme.connectedColor;
      case ConnectionStatus.connecting:
        return AppTheme.connectingColor;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return AppTheme.disconnectedColor;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case ConnectionStatus.connected:
        return connectedIcon;
      case ConnectionStatus.connecting:
        return Icons.sync;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return disconnectedIcon;
    }
  }

  String _getTooltip() {
    switch (status) {
      case ConnectionStatus.connected:
        return '$label connected';
      case ConnectionStatus.connecting:
        return 'Connecting to $label...';
      case ConnectionStatus.disconnected:
        return '$label disconnected';
      case ConnectionStatus.error:
        return 'Error connecting to $label';
    }
  }
}

class ConnectionStatusBar extends StatelessWidget {
  final ConnectionState connectionState;
  final VoidCallback? onRefresh;

  const ConnectionStatusBar({
    super.key,
    required this.connectionState,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          ConnectionIndicator(
            status: connectionState.serverStatus,
            label: 'PC',
            connectedIcon: Icons.computer,
            disconnectedIcon: Icons.computer_outlined,
          ),
          const SizedBox(width: 12),
          ConnectionIndicator(
            status: connectionState.androidStatus,
            label: 'ADB',
            connectedIcon: Icons.phone_android,
            disconnectedIcon: Icons.phone_android_outlined,
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Refresh connection',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
        ],
      ),
    );
  }
}
