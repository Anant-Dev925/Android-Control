import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/data/models/chat_message_model.dart';
import 'package:android_control/data/services/api_service.dart';

class ChatCubit extends Cubit<List<ChatMessage>> {
  final ApiService _apiService;

  ChatCubit({required ApiService apiService})
      : _apiService = apiService,
        super([]);

  void addWelcomeMessage(bool androidConnected) {
    if (state.isEmpty) {
      final message = androidConnected
          ? '✅ Android device connected! How can I help you today?'
          : '⚠️ Android not connected. Please check your connection.';
      
      emit([ChatMessage.assistant(message)]);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(text);
    final loadingMessage = ChatMessage.loading();
    
    emit([...state, userMessage, loadingMessage]);

    final response = await _apiService.sendChat(text, useTools: true);

    final currentMessages = List<ChatMessage>.from(state);
    currentMessages.removeLast();

    if (response.success) {
      final assistantMessage = ChatMessage.assistant(
        response.response ?? 'No response',
        toolCalls: response.toolCalls,
      );
      emit([...currentMessages, assistantMessage]);
    } else {
      final errorMessage = ChatMessage.error(
        response.error ?? 'Failed to get response',
      );
      emit([...currentMessages, errorMessage]);
    }
  }

  void clearMessages() {
    emit([]);
  }
}
