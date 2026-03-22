import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';
import 'package:android_control/presentation/cubit/session_cubit.dart';
import 'package:android_control/core/theme/theme_cubit.dart';
import 'package:android_control/data/models/chat_message_model.dart';
import 'package:android_control/data/models/connection_state_model.dart' as conn;
import 'package:android_control/data/models/session_model.dart';
import 'package:android_control/presentation/widgets/chat_bubble.dart';
import 'package:android_control/presentation/widgets/connection_indicator.dart';
import 'package:android_control/presentation/widgets/quick_actions_bar.dart';
import 'package:android_control/presentation/widgets/command_menu.dart';
import 'package:android_control/presentation/pages/settings_page.dart';
import 'package:android_control/presentation/pages/about_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _welcomeShown = false;
  bool _showCommandMenu = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  void _initSession() async {
    if (!mounted) return;
    
    final chatCubit = context.read<ChatCubit>();
    
    final sessionCubit = context.read<SessionCubit>();
    await sessionCubit.loadSessions();
    
    if (!mounted) return;
    if (sessionCubit.state.sessions.isEmpty) {
      await sessionCubit.createNewSession();
    } else {
      final recentSession = sessionCubit.state.sessions.first;
      await sessionCubit.selectSession(recentSession.id);
    }
    
    if (!mounted) return;
    final sessionState = sessionCubit.state;
    if (sessionState.currentSessionId != null) {
      chatCubit.setSessionId(sessionState.currentSessionId);
      
      if (sessionState.currentMessages.isNotEmpty) {
        chatCubit.loadMessages(sessionState.currentMessages);
      } else {
        await chatCubit.loadCachedMessages();
        if (chatCubit.state.isEmpty) {
          _showWelcome();
        }
      }
    }
  }

  void _showWelcome() {
    if (!_welcomeShown && mounted) {
      _welcomeShown = true;
      final connectionState = context.read<ConnectionCubit>().state;
      context.read<ChatCubit>().addWelcomeMessage(connectionState.isAndroidConnected);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _showCommandMenu = false);
    _focusNode.unfocus();
    context.read<ChatCubit>().sendMessage(text);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.read<SessionCubit>().loadSessions();
    });
  }

  void _showCommandMenu_() {
    setState(() => _showCommandMenu = true);
  }

  void _hideCommandMenu_() {
    setState(() => _showCommandMenu = false);
  }

  void _showRenameDialog(SessionModel session) {
    final textController = TextEditingController(text: session.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Session Name',
            hintText: 'Enter a name for this session',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = textController.text.trim();
              await context.read<SessionCubit>().renameSession(session.id, name);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android AI Control'),
        actions: [
          BlocBuilder<ConnectionCubit, conn.ConnectionState>(
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConnectionIndicator(
                    status: state.serverStatus,
                    label: 'PC',
                    connectedIcon: Icons.computer,
                    disconnectedIcon: Icons.computer_outlined,
                  ),
                  const SizedBox(width: 4),
                  ConnectionIndicator(
                    status: state.androidStatus,
                    label: 'ADB',
                    connectedIcon: Icons.phone_android,
                    disconnectedIcon: Icons.phone_android_outlined,
                  ),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      return IconButton(
                        icon: Icon(
                          themeState.themeMode == AppThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        tooltip: 'Toggle theme',
                        onPressed: () {
                          final current = themeState.themeMode;
                          if (current == AppThemeMode.dark) {
                            context.read<ThemeCubit>().setThemeMode(AppThemeMode.light);
                          } else {
                            context.read<ThemeCubit>().setThemeMode(AppThemeMode.dark);
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            return Column(
              children: [
                AppBar(
                  title: const Text('Sessions'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'New Session',
                      onPressed: () async {
                        final sessionCubit = context.read<SessionCubit>();
                        await sessionCubit.createNewSession();
                        final chatCubit = context.read<ChatCubit>();
                        chatCubit.setSessionId(sessionCubit.state.currentSessionId);
                        chatCubit.loadMessages([]);
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: state.sessions.isEmpty
                      ? const Center(child: Text('No sessions'))
                      : ListView.builder(
                          itemCount: state.sessions.length,
                          itemBuilder: (context, index) {
                            final session = state.sessions[index];
                            final isSelected = session.id == state.currentSessionId;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.chat_bubble,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              title: Text(
                                session.name ?? (session.messageCount > 0 ? session.preview : 'New Session'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('${session.messageCount} messages'),
                              selected: isSelected,
                              onTap: () async {
                                await context.read<SessionCubit>().selectSession(session.id);
                                final chatCubit = context.read<ChatCubit>();
                                chatCubit.setSessionId(session.id);
                                chatCubit.loadMessages(context.read<SessionCubit>().state.currentMessages);
                                if (mounted) Navigator.pop(context);
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'rename') {
                                    _showRenameDialog(session);
                                  } else if (value == 'delete') {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Session'),
                                        content: const Text('Are you sure you want to delete this session?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true && context.mounted) {
                                      await context.read<SessionCubit>().deleteSession(session.id);
                                    }
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Rename'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<ConnectionCubit, conn.ConnectionState>(
            builder: (context, state) {
              if (state.serverStatus != conn.ConnectionStatus.connected) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 18,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Server not connected • ${state.serverMessage}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.read<ConnectionCubit>().reconnect(),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          QuickActionsBar(
            onPasteToChat: (text) {
              _controller.text = text;
              _focusNode.requestFocus();
            },
          ),
          Expanded(
            child: BlocConsumer<ChatCubit, List<ChatMessage>>(
              listener: (_, messages) => _scrollToBottom(),
              builder: (context, messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Start a conversation...'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, index) => ChatBubble(message: messages[index]),
                );
              },
            ),
          ),
          BlocBuilder<ConnectionCubit, conn.ConnectionState>(
            builder: (context, state) {
              return _buildInput(isServerConnected: state.serverStatus == conn.ConnectionStatus.connected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput({bool isServerConnected = true}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showCommandMenu) _buildCommandMenu(),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: isServerConnected,
                    decoration: InputDecoration(
                      hintText: isServerConnected ? 'Ask me anything...' : 'Server not connected',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: !isServerConnected,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    textInputAction: TextInputAction.send,
                    onChanged: (value) {
                      if (isServerConnected) {
                        if (value == '/') {
                          _showCommandMenu_();
                        } else if (value.isEmpty || !value.startsWith('/')) {
                          _hideCommandMenu_();
                        }
                      }
                    },
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.terminal),
                  tooltip: 'Commands',
                  onPressed: isServerConnected ? _showCommandMenu_ : null,
                ),
                const SizedBox(width: 4),
                BlocBuilder<ChatCubit, List<ChatMessage>>(
                  builder: (context, messages) {
                    final isLoading = messages.isNotEmpty && messages.last.isLoading;
                    return FloatingActionButton(
                      onPressed: (isServerConnected && !isLoading) ? _sendMessage : null,
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandMenu() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  onTap: _hideCommandMenu_,
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
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: CommandMenu.commands.map((cmd) {
                return InkWell(
                  onTap: () {
                    _controller.text = cmd.example;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: cmd.example.length),
                    );
                    _hideCommandMenu_();
                  },
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
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
