import 'dart:convert';
import 'dart:io';
import 'package:android_control/core/constants/app_constants.dart';
import 'package:android_control/data/models/chat_message_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppConstants.serverUrl});

  Future<ApiResponse> getStatus() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/api/status'));
      final response = await request.close().timeout(AppConstants.connectionTimeout);
      
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body);
      
      client.close();
      
      return ApiResponse(
        success: response.statusCode == 200,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ChatResponse> sendChat(String message, {bool useTools = true}) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/chat'));
      request.headers.contentType = ContentType.json;
      request.write(json.encode({
        'message': message,
        'useTools': useTools,
      }));
      
      final response = await request.close().timeout(AppConstants.receiveTimeout);
      final body = await response.transform(utf8.decoder).join();
      
      client.close();
      
      if (response.statusCode == 200) {
        final data = json.decode(body);
        return ChatResponse.fromJson(data);
      } else {
        return ChatResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: $body',
        );
      }
    } catch (e) {
      return ChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse> executeAction({
    required String action,
    String? path,
    String? content,
  }) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/execute'));
      request.headers.contentType = ContentType.json;
      
      final body = <String, dynamic>{'action': action};
      if (path != null) body['path'] = path;
      if (content != null) body['content'] = content;
      
      request.write(json.encode(body));
      final response = await request.close().timeout(AppConstants.connectionTimeout);
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      
      client.close();
      
      return ApiResponse(
        success: response.statusCode == 200 && data['success'] == true,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse> reconnect() async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/reconnect'));
      final response = await request.close().timeout(AppConstants.connectionTimeout);
      
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body);
      
      client.close();
      
      return ApiResponse(
        success: response.statusCode == 200,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });
}

class ChatResponse {
  final bool success;
  final String? response;
  final List<ToolCall>? toolCalls;
  final String? error;

  ChatResponse({
    required this.success,
    this.response,
    this.toolCalls,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    List<ToolCall>? toolCalls;
    if (json['toolCalls'] != null) {
      toolCalls = (json['toolCalls'] as List)
          .map((e) => ToolCall(
                name: e['tool'] ?? '',
                arguments: e['arguments'] ?? {},
                result: e['result'],
                error: e['error'],
              ))
          .toList();
    }

    return ChatResponse(
      success: json['response'] != null,
      response: json['response'],
      toolCalls: toolCalls,
      error: json['error'],
    );
  }
}
