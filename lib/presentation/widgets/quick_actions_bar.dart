import 'package:flutter/material.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';

class QuickActionsBar extends StatelessWidget {
  final Function(QuickAction) onAction;

  const QuickActionsBar({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionChip(
              icon: Icons.folder_open,
              label: 'List Files',
              onTap: () => onAction(QuickAction.listFiles),
            ),
            _QuickActionChip(
              icon: Icons.description,
              label: 'Read File',
              onTap: () => onAction(QuickAction.readTest),
            ),
            _QuickActionChip(
              icon: Icons.create_new_folder,
              label: 'New Folder',
              onTap: () => onAction(QuickAction.createFolder),
            ),
            _QuickActionChip(
              icon: Icons.sync,
              label: 'Reconnect',
              onTap: () => onAction(QuickAction.reconnect),
            ),
            _QuickActionChip(
              icon: Icons.info_outline,
              label: 'Status',
              onTap: () => onAction(QuickAction.checkStatus),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
