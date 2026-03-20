import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';
import 'package:android_control/presentation/cubit/session_cubit.dart';
import 'package:android_control/data/models/chat_message_model.dart';
import 'package:android_control/data/models/connection_state_model.dart' as conn;
import 'package:android_control/data/models/session_model.dart';
import 'package:android_control/presentation/widgets/chat_bubble.dart';
import 'package:android_control/presentation/widgets/connection_indicator.dart';
import 'package:android_control/presentation/widgets/quick_actions_bar.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  void _initSession() async {
    if (!mounted) return;
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
      final chatCubit = context.read<ChatCubit>();
      chatCubit.setSessionId(sessionState.currentSessionId);
      
      if (sessionState.currentMessages.isNotEmpty) {
        chatCubit.loadMessages(sessionState.currentMessages);
      } else {
        _showWelcome();
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
    _focusNode.unfocus();
    context.read<ChatCubit>().sendMessage(text);
    _scrollToBottom();
    // Refresh sessions list after sending
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.read<SessionCubit>().loadSessions();
    });
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
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<ConnectionCubit>().checkConnection(),
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
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
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
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Ask me anything...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 5,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ChatCubit, List<ChatMessage>>(
              builder: (context, messages) {
                final isLoading = messages.isNotEmpty && messages.last.isLoading;
                return FloatingActionButton(
                  onPressed: isLoading ? null : _sendMessage,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                );
              },
            ),
          ],
        ),
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
