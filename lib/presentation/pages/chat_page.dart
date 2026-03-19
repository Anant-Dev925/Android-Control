import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/presentation/cubit/chat_cubit.dart';
import 'package:android_control/presentation/cubit/connection_cubit.dart';
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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showWelcomeMessage();
      }
    });
  }

  void _showWelcomeMessage() {
    if (!_welcomeShown) {
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

  void _pasteToChat(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _focusNode.requestFocus();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _focusNode.unfocus();
    
    context.read<ChatCubit>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android AI Control'),
        actions: [
          BlocBuilder<ConnectionCubit, dynamic>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ConnectionStatusBar(
                  connectionState: state,
                  onRefresh: () {
                    context.read<ConnectionCubit>().checkConnection();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          QuickActionsBar(
            onPasteToChat: _pasteToChat,
          ),
          Expanded(
            child: BlocConsumer<ChatCubit, List<dynamic>>(
              listener: (context, state) {
                _scrollToBottom();
              },
              builder: (context, messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Start a conversation...'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ChatCubit, List<dynamic>>(
              builder: (context, messages) {
                final isLoading = messages.isNotEmpty && 
                    messages.last.isLoading == true;
                
                return FloatingActionButton(
                  onPressed: isLoading ? null : _sendMessage,
                  elevation: 2,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
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
