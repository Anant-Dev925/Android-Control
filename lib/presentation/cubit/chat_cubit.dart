import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/data/models/chat_message_model.dart';
import 'package:android_control/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatCubit extends Cubit<List<ChatMessage>> {
  final ApiService _apiService;
  String? _currentSessionId;
  static const String _cacheKey = 'cached_messages';

  ChatCubit({required ApiService apiService})
      : _apiService = apiService,
        super([]);

  String? get currentSessionId => _currentSessionId;

  void setSessionId(String? sessionId) {
    _currentSessionId = sessionId;
  }

  Future<void> loadCachedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        final messages = jsonList.map((m) => _messageFromJson(m)).toList();
        emit(messages);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<void> _cacheMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limitedMessages = messages.length > 20 ? messages.sublist(messages.length - 20) : messages;
      final jsonList = limitedMessages.map((m) => _messageToJson(m)).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // Ignore cache errors
    }
  }

  Map<String, dynamic> _messageToJson(ChatMessage msg) {
    return {
      'id': msg.id,
      'content': msg.content,
      'isUser': msg.isUser,
      'timestamp': msg.timestamp.toIso8601String(),
      'isLoading': msg.isLoading,
      'error': msg.error,
      'toolCalls': msg.toolCalls?.map((t) => {
        'name': t.name,
        'arguments': t.arguments,
        'result': t.result,
        'error': t.error,
      }).toList(),
    };
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      isLoading: json['isLoading'] ?? false,
      error: json['error'],
      toolCalls: json['toolCalls'] != null
          ? (json['toolCalls'] as List).map((t) => ToolCall(
              name: t['name'],
              arguments: Map<String, dynamic>.from(t['arguments'] ?? {}),
              result: t['result'],
              error: t['error'],
            )).toList()
          : null,
    );
  }

  void loadMessages(List<ChatMessage> messages) {
    emit(messages);
    _cacheMessages(messages);
  }

  void addWelcomeMessage(bool androidConnected) {
    if (state.isEmpty) {
      final message = androidConnected
          ? '✅ Android device connected! How can I help you today?'
          : '⚠️ Android not connected. Please check your connection.';
      
      emit([ChatMessage.assistant(message)]);
      _cacheMessages(state);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(text);
    final loadingMessage = ChatMessage.loading();
    
    emit([...state, userMessage, loadingMessage]);

    final response = await _apiService.sendChat(
      text,
      useTools: true,
      sessionId: _currentSessionId,
    );

    if (response.sessionId != null) {
      _currentSessionId = response.sessionId;
    }

    final currentMessages = List<ChatMessage>.from(state);
    currentMessages.removeLast();

    if (response.success) {
      final assistantMessage = ChatMessage.assistant(
        response.response ?? 'No response',
        toolCalls: response.toolCalls,
      );
      final newMessages = [...currentMessages, assistantMessage];
      emit(newMessages);
      _cacheMessages(newMessages);
    } else {
      final errorMessage = ChatMessage.error(
        response.error ?? 'Failed to get response',
      );
      final newMessages = [...currentMessages, errorMessage];
      emit(newMessages);
      _cacheMessages(newMessages);
    }
  }

  void clearMessages() {
    emit([]);
    _cacheMessages([]);
  }
}
