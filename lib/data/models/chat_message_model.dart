import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<ToolCall>? toolCalls;
  final bool isLoading;
  final String? error;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.toolCalls,
    this.isLoading = false,
    this.error,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content, {List<ToolCall>? toolCalls}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      toolCalls: toolCalls,
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  factory ChatMessage.error(String error) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      error: error,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<ToolCall>? toolCalls,
    bool? isLoading,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      toolCalls: toolCalls ?? this.toolCalls,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp, toolCalls, isLoading, error];
}

class ToolCall extends Equatable {
  final String name;
  final Map<String, dynamic> arguments;
  final String? result;
  final String? error;

  const ToolCall({
    required this.name,
    required this.arguments,
    this.result,
    this.error,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      name: json['tool'] ?? '',
      arguments: json['arguments'] ?? {},
      result: json['result'],
      error: json['error'],
    );
  }

  @override
  List<Object?> get props => [name, arguments, result, error];
}
