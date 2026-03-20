import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_control/data/services/api_service.dart';
import 'package:android_control/data/models/session_model.dart';
import 'package:android_control/data/models/chat_message_model.dart';

class SessionState {
  final List<SessionModel> sessions;
  final String? currentSessionId;
  final List<ChatMessage> currentMessages;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.sessions = const [],
    this.currentSessionId,
    this.currentMessages = const [],
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<SessionModel>? sessions,
    String? currentSessionId,
    List<ChatMessage>? currentMessages,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  final ApiService _apiService;

  SessionCubit({required ApiService apiService})
      : _apiService = apiService,
        super(const SessionState());

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true, error: null));
    
    final response = await _apiService.getSessions();
    
    if (response.success && response.sessions != null) {
      emit(state.copyWith(
        sessions: response.sessions,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: response.error,
      ));
    }
  }

  Future<void> selectSession(String sessionId) async {
    emit(state.copyWith(isLoading: true, currentSessionId: sessionId, error: null));
    
    final response = await _apiService.getSessionHistory(sessionId);
    
    if (response.success && response.sessionData != null) {
      final messages = _parseSessionMessages(response.sessionData!);
      emit(state.copyWith(
        currentMessages: messages,
        isLoading: false,
        currentSessionId: sessionId,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: response.error,
      ));
    }
  }

  Future<void> createNewSession() async {
    emit(state.copyWith(isLoading: true, error: null));
    
    final response = await _apiService.createSession();
    
    if (response.success && response.sessionId != null) {
      await loadSessions();
      emit(state.copyWith(
        currentSessionId: response.sessionId,
        currentMessages: [],
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: response.error,
      ));
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final response = await _apiService.deleteSession(sessionId);
    
    if (response.success) {
      await loadSessions();
      
      // If we deleted the current session, create a new one
      if (state.currentSessionId == sessionId) {
        await createNewSession();
      }
    }
  }

  Future<void> renameSession(String sessionId, String name) async {
    final response = await _apiService.renameSession(sessionId, name);
    
    if (response.success) {
      await loadSessions();
    }
  }

  void updateCurrentSession(String sessionId, List<ChatMessage> messages) {
    emit(state.copyWith(
      currentSessionId: sessionId,
      currentMessages: messages,
    ));
  }

  void addMessage(ChatMessage message) {
    emit(state.copyWith(
      currentMessages: [...state.currentMessages, message],
    ));
  }

  void updateLastMessage(ChatMessage message) {
    if (state.currentMessages.isEmpty) return;
    final updatedMessages = List<ChatMessage>.from(state.currentMessages);
    updatedMessages[updatedMessages.length - 1] = message;
    emit(state.copyWith(currentMessages: updatedMessages));
  }

  void clearMessages() {
    emit(state.copyWith(currentMessages: []));
  }

  List<ChatMessage> _parseSessionMessages(Map<String, dynamic> sessionData) {
    final messages = <ChatMessage>[];
    final chatMessages = sessionData['messages'] as List? ?? [];
    
    for (final msg in chatMessages) {
      final role = msg['role'] as String? ?? '';
      final content = msg['content'] as String? ?? '';
      
      if (role == 'user') {
        messages.add(ChatMessage.user(content));
      } else if (role == 'assistant') {
        messages.add(ChatMessage.assistant(content));
      }
    }
    
    return messages;
  }
}
