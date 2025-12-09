import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../config/ai_config.dart';
import '../constants/api_constants.dart';
import '../error/failures.dart';

/// Message format for AI conversation history
class AIMessage {
  const AIMessage({
    required this.role,
    required this.content,
  });

  /// 'user' or 'assistant'
  final String role;

  /// Message content
  final String content;

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

/// Response from AI service
class AIResponse {
  const AIResponse({
    required this.content,
    this.conversationId,
    this.tokensUsed,
  });

  /// AI response text
  final String content;

  /// Conversation ID (if managed by backend)
  final String? conversationId;

  /// Number of tokens used (for tracking)
  final int? tokensUsed;
}

/// Service for AI chat interactions
///
/// This service handles all communication with the AI backend.
/// It supports both mock responses (for development) and real API calls.
///
/// DEVELOPER INTEGRATION:
/// 1. Set AIConfig.useMockResponses = false when backend is ready
/// 2. Configure AIConfig.aiBaseUrl and AIConfig.aiApiKey
/// 3. Adjust the request/response format to match your backend
class AIChatService {
  AIChatService({
    Dio? dio,
  }) : _dio = dio ?? _createDio();

  final Dio _dio;

  /// Creates configured Dio instance
  static Dio _createDio() {
    final baseUrl = AIConfig.useMockResponses
        ? ApiConstants.baseUrl // Use main API when mocking
        : AIConfig.aiBaseUrl;

    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: AIConfig.connectionTimeoutSeconds),
      receiveTimeout: Duration(seconds: AIConfig.responseTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (!AIConfig.useMockResponses) ...{
          'Authorization': 'Bearer ${AIConfig.aiApiKey}',
          ...AIConfig.additionalHeaders,
        },
      },
    ));
  }

  /// Gets an AI response for the user's message
  ///
  /// [conversationId] - ID of the current conversation
  /// [userMessage] - The user's message to respond to
  /// [conversationHistory] - Previous messages for context
  /// [style] - Response style preference ('creative', 'balanced', 'precise')
  ///
  /// Returns `Either<AIFailure, AIResponse>`
  Future<Either<AIFailure, AIResponse>> getResponse({
    required String conversationId,
    required String userMessage,
    List<AIMessage> conversationHistory = const [],
    String style = 'balanced',
  }) async {
    if (AIConfig.useMockResponses) {
      return _getMockResponse(userMessage, conversationHistory);
    }

    return _getApiResponse(
      conversationId: conversationId,
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      style: style,
    );
  }

  /// Makes actual API call to AI backend
  Future<Either<AIFailure, AIResponse>> _getApiResponse({
    required String conversationId,
    required String userMessage,
    required List<AIMessage> conversationHistory,
    required String style,
  }) async {
    try {
      // Build conversation history if enabled
      final history = AIConfig.sendConversationHistory
          ? conversationHistory
              .take(AIConfig.maxHistoryMessages)
              .map((m) => m.toJson())
              .toList()
          : <Map<String, dynamic>>[];

      // Get temperature for style
      final temperature = AIConfig.styleTemperatures[style] ??
          AIConfig.defaultTemperature;

      if (AIConfig.enableDebugLogging) {
        debugPrint('AIChatService: Sending request to AI...');
        debugPrint('  - Conversation ID: $conversationId');
        debugPrint('  - Message: ${userMessage.substring(0, min(50, userMessage.length))}...');
        debugPrint('  - History length: ${history.length}');
        debugPrint('  - Style: $style (temp: $temperature)');
      }

      final response = await _dio.post(
        ApiConstants.aiChat,
        data: {
          'conversation_id': conversationId,
          'message': userMessage,
          'history': history,
          'style': style,
          'temperature': temperature,
          'max_tokens': AIConfig.maxResponseTokens,
          'system_prompt': AIConfig.systemPrompt,
          'model': AIConfig.defaultModel,
        },
      );

      // Parse response
      // DEVELOPER: Adjust parsing based on your backend response format
      final data = response.data;

      if (data == null || data['response'] == null) {
        return Left(AIFailure.invalidResponse());
      }

      if (AIConfig.enableDebugLogging) {
        debugPrint('AIChatService: Received response successfully');
      }

      return Right(AIResponse(
        content: data['response'] as String,
        conversationId: data['conversation_id'] as String?,
        tokensUsed: data['tokens_used'] as int?,
      ));
    } on DioException catch (e) {
      final failure = _handleDioError(e);
      if (AIConfig.enableDebugLogging) {
        debugPrint('AIChatService: API error - ${failure.message}');
      }
      return Left(failure);
    } catch (e) {
      if (AIConfig.enableDebugLogging) {
        debugPrint('AIChatService: Unexpected error - $e');
      }
      return Left(AIFailure.unknown(e.toString()));
    }
  }

  /// Returns mock response for development
  Future<Either<AIFailure, AIResponse>> _getMockResponse(
    String userMessage,
    List<AIMessage> conversationHistory,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (AIConfig.enableDebugLogging) {
      debugPrint('AIChatService: Generating mock response...');
      debugPrint('  - User message: ${userMessage.substring(0, min(50, userMessage.length))}...');
    }

    // Generate contextual mock response
    final response = _generateMockResponse(userMessage);

    return Right(AIResponse(
      content: response,
      conversationId: null,
      tokensUsed: null,
    ));
  }

  /// Generates a contextual mock response based on user message
  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Greeting responses
    if (lowerMessage.contains('hello') ||
        lowerMessage.contains('hi') ||
        lowerMessage.contains('hey')) {
      return _randomFrom([
        "Hello! I'm Apothy, your AI companion. How can I help you today?",
        "Hi there! It's great to chat with you. What's on your mind?",
        "Hey! I'm here to help. What would you like to talk about?",
      ]);
    }

    // How are you responses
    if (lowerMessage.contains('how are you') ||
        lowerMessage.contains('how\'s it going')) {
      return _randomFrom([
        "I'm doing well, thank you for asking! I'm here and ready to help you with whatever you need.",
        "I'm great! As an AI, I'm always at my best when I get to help someone. What can I do for you?",
      ]);
    }

    // Help responses
    if (lowerMessage.contains('help') || lowerMessage.contains('can you')) {
      return _randomFrom([
        "Of course! I'd be happy to help. I can assist with questions, provide information, or just have a friendly conversation. What do you need?",
        "I'm here to help! Whether you want to talk about something specific or just chat, I'm all ears. What's on your mind?",
      ]);
    }

    // Thank you responses
    if (lowerMessage.contains('thank') || lowerMessage.contains('thanks')) {
      return _randomFrom([
        "You're welcome! I'm always happy to help. Is there anything else you'd like to discuss?",
        "My pleasure! Don't hesitate to reach out if you need anything else.",
      ]);
    }

    // Goodbye responses
    if (lowerMessage.contains('bye') ||
        lowerMessage.contains('goodbye') ||
        lowerMessage.contains('see you')) {
      return _randomFrom([
        "Goodbye! It was nice chatting with you. Take care and come back anytime!",
        "See you later! Remember, I'm here whenever you need someone to talk to.",
      ]);
    }

    // Feeling responses
    if (lowerMessage.contains('feeling') ||
        lowerMessage.contains('feel') ||
        lowerMessage.contains('sad') ||
        lowerMessage.contains('happy') ||
        lowerMessage.contains('stressed') ||
        lowerMessage.contains('anxious')) {
      return _randomFrom([
        "Thank you for sharing how you're feeling with me. It takes courage to express our emotions. Would you like to talk more about what's going on?",
        "I appreciate you opening up to me. Your feelings are valid, and I'm here to listen. Would you like to tell me more?",
        "It sounds like you're going through something. I'm here for you. Sometimes just talking about things can help. What else is on your mind?",
      ]);
    }

    // Question responses
    if (lowerMessage.contains('?') ||
        lowerMessage.startsWith('what') ||
        lowerMessage.startsWith('why') ||
        lowerMessage.startsWith('how') ||
        lowerMessage.startsWith('when') ||
        lowerMessage.startsWith('where')) {
      return _randomFrom([
        "That's a great question! While I'm currently running in demo mode, I'll be able to provide more detailed answers once the full AI integration is complete. For now, feel free to ask me anything - I'll do my best to help!",
        "Interesting question! I'm Apothy, your AI companion. Right now I'm operating in demo mode, but soon I'll be able to give you more comprehensive responses. What else would you like to know?",
      ]);
    }

    // Default responses
    return _randomFrom([
      "Thank you for sharing that with me. I'm here to listen and chat. Is there anything specific you'd like to discuss?",
      "I appreciate you reaching out! I'm Apothy, and I'm here to be a supportive companion. What else is on your mind?",
      "That's interesting! I'd love to hear more about your thoughts. Feel free to share anything you'd like.",
      "I'm glad you're here! As your AI companion, I'm always ready to chat. What would you like to talk about?",
    ]);
  }

  /// Returns random item from list
  String _randomFrom(List<String> options) {
    return options[Random().nextInt(options.length)];
  }

  /// Converts Dio errors to AIFailure
  AIFailure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AIFailure.timeout();

      case DioExceptionType.badResponse:
        return _handleHttpError(e.response?.statusCode, e.response?.data);

      case DioExceptionType.connectionError:
        return AIFailure.serviceUnavailable();

      case DioExceptionType.cancel:
        return AIFailure.unknown('Request was cancelled');

      default:
        return AIFailure.unknown(e.message);
    }
  }

  /// Handles HTTP status code errors
  AIFailure _handleHttpError(int? statusCode, dynamic data) {
    final errorMessage = data is Map ? data['error']?.toString() : null;

    switch (statusCode) {
      case 400:
        return AIFailure.invalidResponse();
      case 401:
        return AIFailure.authenticationFailed();
      case 403:
        return AIFailure.contentBlocked();
      case 429:
        return AIFailure.rateLimited();
      case 500:
      case 502:
      case 503:
        return AIFailure.serviceUnavailable();
      default:
        return AIFailure.unknown(errorMessage ?? 'HTTP $statusCode error');
    }
  }

  /// Disposes resources
  void dispose() {
    _dio.close();
  }
}
