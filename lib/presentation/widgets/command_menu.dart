import 'package:flutter/material.dart';

class CommandMenuItem {
  final String command;
  final String description;
  final String example;
  final IconData icon;

  const CommandMenuItem({
    required this.command,
    required this.description,
    required this.example,
    required this.icon,
  });
}

class CommandMenu extends StatelessWidget {
  final Function(String) onSelect;
  final VoidCallback onDismiss;

  const CommandMenu({
    super.key,
    required this.onSelect,
    required this.onDismiss,
  });

  static const List<CommandMenuItem> commands = [
    CommandMenuItem(
      command: '/read',
      description: 'Read a file',
      example: '/read notes.txt',
      icon: Icons.description,
    ),
    CommandMenuItem(
      command: '/write',
      description: 'Create or write to a file',
      example: '/write summary.txt with content',
      icon: Icons.edit,
    ),
    CommandMenuItem(
      command: '/list',
      description: 'List files in a folder',
      example: '/list /sdcard/Download',
      icon: Icons.folder_open,
    ),
    CommandMenuItem(
      command: '/search',
      description: 'Search for files',
      example: '/search photos',
      icon: Icons.search,
    ),
    CommandMenuItem(
      command: '/rename',
      description: 'Rename or move a file',
      example: '/rename file.txt to new.txt',
      icon: Icons.drive_file_rename_outline,
    ),
    CommandMenuItem(
      command: '/copy',
      description: 'Copy a file',
      example: '/copy file.txt to backup/',
      icon: Icons.copy,
    ),
    CommandMenuItem(
      command: '/delete',
      description: 'Delete a file or folder',
      example: '/delete oldfile.txt',
      icon: Icons.delete,
    ),
    CommandMenuItem(
      command: '/mkdir',
      description: 'Create a directory',
      example: '/mkdir newfolder',
      icon: Icons.create_new_folder,
    ),
    CommandMenuItem(
      command: '/storage',
      description: 'Show storage info',
      example: '/storage',
      icon: Icons.storage,
    ),
    CommandMenuItem(
      command: '/battery',
      description: 'Show battery status',
      example: '/battery',
      icon: Icons.battery_charging_full,
    ),
    CommandMenuItem(
      command: '/specs',
      description: 'Show device specifications',
      example: '/specs',
      icon: Icons.smartphone,
    ),
    CommandMenuItem(
      command: '/info',
      description: 'Get file information',
      example: '/info notes.txt',
      icon: Icons.info_outline,
    ),
    CommandMenuItem(
      command: '/train',
      description: 'Train AI with custom knowledge',
      example: '/train My name is John',
      icon: Icons.school,
    ),
    CommandMenuItem(
      command: '/forget',
      description: 'Clear trained knowledge',
      example: '/forget',
      icon: Icons.psychology,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 320,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.terminal,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Commands',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: commands.length,
              itemBuilder: (context, index) {
                final cmd = commands[index];
                return InkWell(
                  onTap: () => onSelect(cmd.example),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            cmd.icon,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cmd.command,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                cmd.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cmd.example,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
