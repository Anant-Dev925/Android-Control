import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/presentation/cubit/session_cubit.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/data/models/session_model.dart';

class SessionsDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const SessionsDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              if (state.isLoading && state.sessions.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state.sessions.isEmpty)
                Expanded(child: _buildEmptyState(context))
              else
                Expanded(child: _buildSessionsList(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.history, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Session',
              onPressed: () => _createNewSession(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _createNewSession(context),
              icon: const Icon(Icons.add),
              label: const Text('New Session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, SessionState state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.sessions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        final isSelected = session.id == state.currentSessionId;
        
        return SessionTile(
          session: session,
          isSelected: isSelected,
          onTap: () => _selectSession(context, session),
          onDelete: () => _deleteSession(context, session),
        );
      },
    );
  }

  void _createNewSession(BuildContext context) async {
    final sessionCubit = context.read<SessionCubit>();
    await sessionCubit.createNewSession();
    
    final state = sessionCubit.state;
    if (state.currentSessionId != null) {
      final chatCubit = context.read<ChatCubit>();
      chatCubit.setSessionId(state.currentSessionId);
      chatCubit.loadMessages([]);
    }
    
    onClose();
  }

  void _selectSession(BuildContext context, SessionModel session) async {
    final sessionCubit = context.read<SessionCubit>();
    await sessionCubit.selectSession(session.id);
    
    final chatCubit = context.read<ChatCubit>();
    chatCubit.setSessionId(session.id);
    chatCubit.loadMessages(sessionCubit.state.currentMessages);
    
    onClose();
  }

  void _deleteSession(BuildContext context, SessionModel session) async {
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

    if (confirmed == true) {
      if (!context.mounted) return;
      final sessionCubit = context.read<SessionCubit>();
      await sessionCubit.deleteSession(session.id);
      
      final state = sessionCubit.state;
      if (state.currentSessionId != null) {
        if (!context.mounted) return;
        final chatCubit = context.read<ChatCubit>();
        chatCubit.setSessionId(state.currentSessionId);
        chatCubit.loadMessages(state.currentMessages);
      }
    }
  }
}

class SessionTile extends StatelessWidget {
  final SessionModel session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SessionTile({
    super.key,
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: CircleAvatar(
        child: const Icon(Icons.chat_bubble, size: 20),
      ),
      title: Text(
        session.preview.isNotEmpty ? session.preview : 'New session',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${session.formattedDate} • ${session.messageCount} msgs'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
