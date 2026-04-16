import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:vocal_lens/Model/chat_message_model.dart';

enum AIControllerState {
  idle,
  downloading,
  loading,
  ready,
  thinking,
  error,
}

class ChatWithAIController with ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────
  AIControllerState _state = AIControllerState.idle;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  String _streamingResponse = '';
  InferenceModel? _model;
  InferenceChat? _chat;

  // ─── Text controller (your UI uses this directly) ─────────────
  final TextEditingController messageController = TextEditingController();

  // ─── Chat history (internal — uses your model) ────────────────
  final List<ChatMessageModel> _messages = [];

  // ─── Search ───────────────────────────────────────────────────
  String _searchQuery = '';

  // ─── Getters ──────────────────────────────────────────────────
  AIControllerState get state => _state;
  double get downloadProgress => _downloadProgress;
  String? get errorMessage => _errorMessage;
  String get streamingResponse => _streamingResponse;
  bool get isReady => _state == AIControllerState.ready;
  bool get isThinking => _state == AIControllerState.thinking;
  bool get isDownloading => _state == AIControllerState.downloading;

  // ✅ Your UI checks this for the spinner
  bool get isLoading =>
      _state == AIControllerState.thinking ||
      _state == AIControllerState.loading ||
      _state == AIControllerState.downloading;

  // ✅ Your UI uses List<Map<String, dynamic>> with 'question'/'answer' keys
  // This converts ChatMessageModel pairs into the format your UI expects
  List<Map<String, dynamic>> get filteredMessages {
    // Build paired messages: each pair is {question, answer}
    final List<Map<String, dynamic>> paired = [];

    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];

      if (msg.isUser) {
        // Look ahead for the AI response
        final String? answer =
            (i + 1 < _messages.length && !_messages[i + 1].isUser)
                ? _messages[i + 1].text
                : null;

        final Map<String, dynamic> pair = {'question': msg.text};
        if (answer != null) pair['answer'] = answer;

        // If AI is currently streaming, show live streaming text as answer
        if (answer == null &&
            _state == AIControllerState.thinking &&
            _streamingResponse.isNotEmpty) {
          pair['answer'] = _streamingResponse;
        }

        paired.add(pair);
      }
    }

    // If no search query, return all
    if (_searchQuery.trim().isEmpty) return paired;

    // Filter by search query across both question and answer
    return paired.where((msg) {
      final q = msg['question']?.toString().toLowerCase() ?? '';
      final a = msg['answer']?.toString().toLowerCase() ?? '';
      return q.contains(_searchQuery.toLowerCase()) ||
          a.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // ─── Search ───────────────────────────────────────────────────
  // ✅ Your UI calls this: chatController.setSearchQuery(query)
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Plugin init ──────────────────────────────────────────────
  // Call once in main() before runApp()
  static Future<void> initializePlugin() async {
    await FlutterGemma.initialize();
  }

  // ─── Model init ───────────────────────────────────────────────
  // Call after controller is created via Provider
  Future<void> initializeModel() async {
    try {
      _setState(AIControllerState.downloading);

      final isInstalled = await FlutterGemma.isModelInstalled(
        'gemma3-1b-it-int4.task',
      );

      if (!isInstalled) {
        await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
            .fromNetwork(
          'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task',
        )
            .withProgress((int progress) {
          _downloadProgress = progress / 100.0;
          notifyListeners();
        }).install();
      }

      _setState(AIControllerState.loading);

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );

      _chat = await _model!.createChat();

      _setState(AIControllerState.ready);
    } catch (e) {
      _setError('Failed to initialize AI model: $e');
      log('ChatWithAIController initializeModel error: $e');
    }
  }

  // ─── Send message ─────────────────────────────────────────────
  // ✅ Your UI calls this: chatController.searchQuery()
  // Reads from messageController automatically
  Future<void> searchQuery() async {
    final userText = messageController.text.trim();
    await sendMessage(userText);
  }

  // Core send — also callable directly from VoiceController
  Future<String> sendMessage(String userText) async {
    if (_state != AIControllerState.ready) {
      log('Model not ready. Current state: $_state');
      return '';
    }

    if (userText.trim().isEmpty) return '';

    // Clear input field
    messageController.clear();

    // Add user message
    _messages.add(ChatMessageModel(text: userText.trim(), isUser: true));
    _streamingResponse = '';
    _setState(AIControllerState.thinking);

    try {
      await _chat!.addQueryChunk(
        Message.text(text: userText.trim(), isUser: true),
      );

      final StringBuffer fullResponse = StringBuffer();

      await for (final token in _chat!.generateChatResponseAsync()) {
        fullResponse.write(token);
        _streamingResponse = fullResponse.toString();
        notifyListeners(); // UI updates word-by-word as response streams
      }

      final responseText = fullResponse.toString().trim();

      // Add AI response
      _messages.add(ChatMessageModel(text: responseText, isUser: false));
      _streamingResponse = '';
      _setState(AIControllerState.ready);

      return responseText;
    } catch (e) {
      _setError('Failed to generate response: $e');
      log('ChatWithAIController sendMessage error: $e');
      return '';
    }
  }

  // ─── Clear conversation ───────────────────────────────────────
  Future<void> clearConversation() async {
    if (_model == null) return;

    try {
      _chat = await _model!.createChat();
      _messages.clear();
      _streamingResponse = '';
      _searchQuery = '';
      messageController.clear();
      _setState(AIControllerState.ready);
    } catch (e) {
      _setError('Failed to clear conversation: $e');
      log('ChatWithAIController clearConversation error: $e');
    }
  }

  // ─── Retry after error ────────────────────────────────────────
  Future<void> retryInitialization() async {
    _errorMessage = null;
    _downloadProgress = 0.0;
    await initializeModel();
  }

  // ─── Stop generation ──────────────────────────────────────────
  void stopGeneration() {
    try {
      _streamingResponse = '';
      _setState(AIControllerState.ready);
    } catch (e) {
      log('ChatWithAIController stopGeneration error: $e');
    }
  }

  // ─── Private helpers ──────────────────────────────────────────
  void _setState(AIControllerState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AIControllerState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // ─── Dispose ──────────────────────────────────────────────────
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
