import 'package:flutter/material.dart';

class QuickActionsBar extends StatelessWidget {
  final Function(String) onPasteToChat;

  const QuickActionsBar({
    super.key,
    required this.onPasteToChat,
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
              onTap: () => onPasteToChat('List files in /sdcard/Download'),
            ),
            _QuickActionChip(
              icon: Icons.description,
              label: 'Read File',
              onTap: () => onPasteToChat('Read /sdcard/test.txt'),
            ),
            _QuickActionChip(
              icon: Icons.create_new_folder,
              label: 'New Folder',
              onTap: () => onPasteToChat('Create folder /sdcard/TestFolder'),
            ),
            _QuickActionChip(
              icon: Icons.summarize,
              label: 'Read PDF',
              onTap: () => onPasteToChat('Read /sdcard/Download/NGA.pdf'),
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
