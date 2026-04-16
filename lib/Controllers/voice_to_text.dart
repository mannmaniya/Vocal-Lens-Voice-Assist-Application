import 'dart:async';
import 'dart:developer';
import 'package:audio_session/audio_session.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vocal_lens/Keys/api_keys.dart';
import 'package:vocal_lens/Views/ChatSection/chat_section.dart';
import 'package:vocal_lens/Views/ConnectionsRequestPage/connection_request_page.dart';
import 'package:vocal_lens/Views/FavouritesResponsesPage/favourite_responses_page.dart';
import 'package:vocal_lens/Views/HowToUsePage/how_to_use_page.dart';
import 'package:vocal_lens/Views/PastResponsesPage/past_responses_page.dart';
import 'package:vocal_lens/Views/UserSettingsPage/user_settings_page.dart';
import 'package:vocal_lens/Views/VoiceModificationPage/voice_modification_page.dart';

class VoiceToTextController extends ChangeNotifier {
  // Constants
  static const int _dailySearchLimit = 3;
  static const String _lastSearchDateKey = 'lastSearchDate';
  static const String _searchCountKey = 'searchCount';
  static const String _apiKey = ApiKeys.geminiApiKey;
  static const int dailySearchLimit = 3;

  // Speech services
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  PorcupineManager? _porcupineManager;
  final FlutterTts _textToSpeech = FlutterTts();

  // State variables
  bool _isListening = false;
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _isWakeWordActive = true;
  String _text = "Press the mic to start speaking...";
  String? _lastSpokenAnswer;

  // Voice settings
  String _voice = "en-us";
  double _pitch = 1.0;
  double _speechRate = 0.5;
  int _micDuration = 5;
  final List<String> _voiceModels = [];

  List<String> get voiceModels => _voiceModels;

  // Data storage
  final GetStorage _storage = GetStorage();
  final List<String> _history = [];
  final List<String> _favoritesList = [];
  final List<String> _pinnedList = [];
  final List<Map<String, dynamic>> _responses = [];
  final TextEditingController _searchFieldController = TextEditingController();

  // Getters
  bool get isListening => _isListening;
  bool get isLoading => _isLoading;
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  bool get isWakeWordActive => _isWakeWordActive;
  String get text => _text;
  String? get lastSpokenAnswer => _lastSpokenAnswer;
  String get voice => _voice;
  double get pitch => _pitch;
  double get speechRate => _speechRate;
  int get micDuration => _micDuration;
  List<String> get history => _history;
  List<String> get favoritesList => _favoritesList;
  List<String> get pinnedList => _pinnedList;
  List<Map<String, dynamic>> get responses => _responses;
  TextEditingController get searchFieldController => _searchFieldController;
  bool get isButtonEnabled => _searchFieldController.text.isNotEmpty;
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Timer for mic duration
  Timer? _listeningTimer;

  VoiceToTextController() {
    _initializeServices();
    _loadPreferences();
    _setupListeners();
    _initializeWakeWord();
    initializeSpeech();
  }

  Future<void> _initializeServices() async {
    try {
      await _configureAudioSession();
      await _initializeTts();
      await _initializeSpeechToText();
      await _initializeWakeWord();
      log('All services initialized successfully');
    } catch (e) {
      log('Error initializing services: $e');
      _updateStatus("Failed to initialize services. Please restart the app.");
    }
  }

  int get remainingSearchesToday {
    final lastSearchDate = _storage.read<String>(_lastSearchDateKey);
    final currentDate = DateTime.now().toIso8601String().substring(0, 10);

    if (lastSearchDate != currentDate) {
      // New day, reset counter
      return dailySearchLimit;
    }

    final searchCount = _storage.read<int>(_searchCountKey) ?? 0;
    return dailySearchLimit - searchCount;
  }

  void _setupListeners() {
    _searchFieldController.addListener(() {
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      log("TTS Error: $msg");
      _isSpeaking = false;
      _isPaused = false;
      notifyListeners();
    });
  }

  Future<void> _loadPreferences() async {
    _voice = _storage.read<String>('voice') ?? "en-us";
    _pitch = _storage.read<double>('pitch') ?? 1.0;
    _speechRate = _storage.read<double>('speechRate') ?? 0.5;
    _micDuration = _storage.read<int>('micDuration') ?? 5;

    _history
        .addAll((_storage.read<List<dynamic>>('history') ?? []).cast<String>());
    _favoritesList.addAll(
        (_storage.read<List<dynamic>>('favorites') ?? []).cast<String>());
    _pinnedList
        .addAll((_storage.read<List<dynamic>>('pinned') ?? []).cast<String>());

    // Initialize TTS with loaded preferences
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(_pitch);
    await flutterTts.setSpeechRate(_speechRate);
  }

  // ========== Usage Limit Management ==========
  bool _checkDailyLimit() {
    final lastSearchDate = _storage.read<String>(_lastSearchDateKey);
    final currentDate = DateTime.now().toIso8601String().substring(0, 10);

    if (lastSearchDate != currentDate) {
      // New day, reset counter
      _storage.write(_lastSearchDateKey, currentDate);
      _storage.write(_searchCountKey, 0);
      return true;
    }

    final searchCount = _storage.read<int>(_searchCountKey) ?? 0;
    return searchCount < _dailySearchLimit;
  }

  void _incrementSearchCount() {
    final currentCount = _storage.read<int>(_searchCountKey) ?? 0;
    _storage.write(_searchCountKey, currentCount + 1);
  }

  // ========== Speech-to-Text Methods ==========
  bool _isSpeechInitialized = false;

  Future<void> _initializeSpeechToText() async {
    if (_isSpeechInitialized) return;

    try {
      bool available = await speechToText.initialize(
        onStatus: (status) {
          log("Speech recognition status: $status");
          if (status == "notListening" || status == "done") {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          log("Speech recognition error: ${error.errorMsg}, permanent: ${error.permanent}");
          _updateStatus("Error: ${error.errorMsg}");
          _isListening = false;
          notifyListeners();
        },
      );

      _isSpeechInitialized = available;
      if (!available) {
        _text = "Speech recognition unavailable";
        notifyListeners();
      }
    } catch (e) {
      _text = "Failed to initialize speech recognition";
      log("Speech initialization error: $e");
      notifyListeners();
    }
  }

  Future<void> initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => log('Speech recognition status: $status'),
        onError: (errorNotification) =>
            log('Speech recognition error: $errorNotification'),
      );
      if (!available) {
        log("Speech recognition is not available.");
      }
    } catch (e) {
      log("Error initializing speech recognition: $e");
    }
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  // bool _isRequestingPermission = false;

  Future<bool> ensureMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;

      if (status.isGranted) {
        log('Microphone permission already granted.');
        return true;
      }

      if (status.isDenied || status.isRestricted) {
        final result = await Permission.microphone.request();
        if (result.isGranted) {
          log('Microphone permission granted after request.');
          return true;
        } else {
          log('Microphone permission denied.');
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        log('Microphone permission permanently denied.');
        Fluttertoast.showToast(
          msg: 'Permission permanently denied. Enable it in settings.',
        );
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      log("Microphone permission error: $e");
      return false;
    }
  }

  Future<void> startListening() async {
    try {
      if (!await ensureMicrophonePermission()) {
        _updateStatus("Microphone permission required");
        await _speak("Please enable microphone permissions in settings");
        return;
      }

      if (!_isSpeechInitialized) {
        await _initializeSpeechToText();
        if (!_isSpeechInitialized) {
          _updateStatus("Speech recognition not ready");
          await _speak("Speech recognition is not ready. Please try again.");
          return;
        }
      }

      if (speechToText.isListening) await speechToText.stop();
      if (_isSpeaking) await flutterTts.stop();

      _isListening = true;
      _text = "Listening...";
      notifyListeners();

      // Cancel any existing timer
      _listeningTimer?.cancel();
      _listeningTimer = Timer(
          Duration(
            seconds: _micDuration,
          ), () {
        log("Auto-stopping after $_micDuration seconds");
        stopListening();
        _speak("Stopped listening after $_micDuration seconds");
      });

      // Prompt before listening
      await _speak("I'm listening. Please say your command now.");
      await Future.delayed(const Duration(
        milliseconds: 500,
      ));

      await speechToText.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            _processVoiceInput(
                result.recognizedWords.trim(), result.finalResult);
          }
        },
        listenFor: Duration(seconds: _micDuration + 5),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_US',
      );

      log("Started listening...");
    } catch (e) {
      log("Listening error: $e");
      _updateStatus("Error starting listening");
      _isListening = false;
      notifyListeners();
      await _speak("Sorry, I couldn't start listening. Please try again.");
    }
  }

  void _processVoiceInput(String text, bool isFinal) {
    log("Processing voice input: '$text' (isFinal: $isFinal)");

    // Update UI with what we're hearing
    _text = text;
    notifyListeners();

    // Only process commands if we have substantial input
    if (text.length > 3 && !_isCommonFillerWord(text)) {
      // For final results, process immediately
      if (isFinal) {
        log("Processing final voice input: '$text'");
        handleVoiceCommands(text);
        if (text.isNotEmpty) {
          _searchFieldController.text = text;
        }
      }
      // For partial results, only process if it looks like a command
      else if (_looksLikeCommand(text)) {
        log("Processing potential command from partial result: '$text'");
        handleVoiceCommands(text);
      }
    }
  }

  void handleVoiceInput() {
    _textToSpeech.stop();
    startListening();
  }

  void _updateStatus(String message) {
    _text = message;
    notifyListeners();
  }

  Future<bool> initSpeechToText() async {
    try {
      bool success = await speechToText.initialize(
        onError: (error) => log("Speech Error: $error"),
        onStatus: (status) => log("Speech Status: $status"),
      );
      log("Initialization success: $success");
      return success;
    } catch (e) {
      log("Initialization failed: $e");
      return false;
    }
  }

  Future<void> testListening() async {
    final stt.SpeechToText speech = stt.SpeechToText();

    bool initialized = await speech.initialize();
    if (!initialized) {
      log("Failed to initialize");
      return;
    }

    log("Starting to listen...");
    speech.listen(
      onResult: (result) {
        log("Heard: ${result.recognizedWords}");
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 1),
    );
  }

  // void _handleSpeechError(String error) {
  //   log('Speech Error: $error');
  //   _updateStatus("Error: $error");
  //   _isListening = false;
  //   notifyListeners();
  // }

  Future<bool> checkSpeechRecognitionAvailable() async {
    try {
      bool available = await speechToText.initialize();
      if (!available) {
        _updateStatus("Speech recognition not available");
        return false;
      }
      return true;
    } catch (e) {
      _updateStatus("Speech recognition error");
      return false;
    }
  }

  void stopListening() async {
    try {
      log("Stopping listening...");
      _listeningTimer?.cancel();

      if (speechToText.isListening) {
        await speechToText.stop();
      }

      _isListening = false;
      _text = "Press the mic to start speaking...";
      notifyListeners();
      log("Listening stopped successfully");

      // Provide feedback if we didn't hear anything
      if (_text.isEmpty ||
          _text == "Listening..." ||
          _text == "Press the mic to start speaking...") {
        await _speak("I didn't hear anything. Please try again.");
      }
    } catch (e) {
      log("Error stopping listening: $e");
      _isListening = false;
      notifyListeners();
      await _speak("There was an error stopping the microphone.");
    }
  }

  void toggleListening() {
    _isListening ? stopListening() : startListening();
  }

  // ========== Text-to-Speech Methods ==========
  Future<void> _initializeTts() async {
    await flutterTts.awaitSpeakCompletion(true);
    await getAvailableVoices();
  }

  Future<void> getAvailableVoices() async {
    final availableVoices = await flutterTts.getVoices;
    final voiceModels = availableVoices
        .map<String>((voice) => voice['name'] as String)
        .toList();

    if (voiceModels.isNotEmpty && !voiceModels.contains(_voice)) {
      _voice = voiceModels[0];
      _saveVoice();
    }
  }

  Future<void> setVoice(String newVoice) async {
    final availableVoices = await flutterTts.getVoices;
    if (availableVoices.any((v) => v['name'] == newVoice)) {
      _voice = newVoice;
      await flutterTts.setVoice({"name": newVoice, "locale": "en-US"});
      _saveVoice();
      notifyListeners();
    }
  }

  void setPitch(double newPitch) {
    _pitch = newPitch;
    flutterTts.setPitch(_pitch);
    _savePitch();
    notifyListeners();
  }

  void setSpeechRate(double newSpeechRate) {
    _speechRate = newSpeechRate;
    flutterTts.setSpeechRate(_speechRate);
    _saveSpeechRate();
    notifyListeners();
  }

  Future<void> previewVoice() async {
    if (_isSpeaking) return;

    _isSpeaking = true;
    notifyListeners();

    try {
      await flutterTts.speak("Hello! This is how your selected voice sounds.");
    } catch (e) {
      log("Error during TTS preview: $e");
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> readOrPromptResponse() async {
    if (_responses.isEmpty) {
      await _speak("Please search for a question or request first.");
      return;
    }

    final currentAnswer = _responses.last['answer'] ?? "No answer available";
    await _speak(currentAnswer);
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) return;

    _isSpeaking = true;
    _lastSpokenAnswer = text;
    notifyListeners();

    try {
      await flutterTts.speak(text);
    } catch (e) {
      log("Error during TTS: $e");
    }
  }

  void stopSpeaking() {
    _isSpeaking = false;
    flutterTts.stop();
    notifyListeners();
  }

  void pauseSpeaking() {
    if (_isSpeaking) {
      _isSpeaking = false;
      _isPaused = true;
      flutterTts.stop();
      notifyListeners();
    }
  }

  void resumeSpeaking() {
    if (!_isSpeaking && _isPaused && _lastSpokenAnswer != null) {
      _isSpeaking = true;
      _isPaused = false;
      flutterTts.speak(_lastSpokenAnswer!);
      notifyListeners();
    }
  }

  // ========== Wake Word Detection ==========
  Future<void> _initializeWakeWord() async {
    try {
      await _initializeWithApiKey(ApiKeys.picoVoiceApiKey);
    } catch (e) {
      log("Primary API key failed: $e. Trying secondary key...");
      try {
        await _initializeWithApiKey(ApiKeys.picoVoiceApiKey2);
      } catch (e) {
        log("Both API keys failed: $e. Wake word detection disabled.");
      }
    }
  }

  Future<void> _initializeWithApiKey(String apiKey) async {
    _porcupineManager = await PorcupineManager.fromKeywordPaths(
      apiKey,
      ["Assets/Vocal_en_android_v3_0_0.ppn"],
      _onWakeWordDetected,
    );
    await _porcupineManager?.start();
  }

  void _onWakeWordDetected(int keywordIndex) async {
    log("Wake word detected!");
    await _speak("Hello User, You can now use Voice Commands!");
    startListening();
  }

  void toggleWakeWordDetection() async {
    if (_isWakeWordActive) {
      await _porcupineManager?.stop();
    } else {
      await _porcupineManager?.start();
    }
    _isWakeWordActive = !_isWakeWordActive;
    notifyListeners();
  }

  // ========== AI Search Methods ==========
  Future<void> searchYourQuery() async {
    if (!_checkDailyLimit()) {
      await _speak(
          "You've reached your daily search limit. Try again tomorrow.");
      return;
    }

    final prompt = _searchFieldController.text.trim();
    if (prompt.isEmpty) return;

    _responses.clear();
    _history.add(prompt);
    _saveHistory();
    _incrementSearchCount();

    _isLoading = true;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: _apiKey);
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        _responses.add({
          "question": prompt,
          "answer": response.text,
        });
        await readOrPromptResponse();
      }
    } catch (e) {
      log("Error during query search: $e");
      await _speak("Sorry, there was an error processing your request.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== Data Management ==========
  void addToFavorites(String response) {
    if (!_favoritesList.contains(response)) {
      _favoritesList.add(response);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFromFavorites(String response) {
    _favoritesList.remove(response);
    _saveFavorites();
    notifyListeners();
  }

  void togglePin(String response) {
    if (_pinnedList.contains(response)) {
      _pinnedList.remove(response);
    } else {
      _pinnedList.add(response);
    }
    _savePinned();
    notifyListeners();
  }

  void deleteHistory(String item) {
    _history.remove(item);
    _saveHistory();
    notifyListeners();
  }

  void deleteAllHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  // ========== Storage Methods ==========
  void _saveVoice() => _storage.write('voice', _voice);
  void _savePitch() => _storage.write('pitch', _pitch);
  void _saveSpeechRate() => _storage.write('speechRate', _speechRate);
  void _saveHistory() => _storage.write('history', _history);
  void _saveFavorites() => _storage.write('favorites', _favoritesList);
  void _savePinned() => _storage.write('pinned', _pinnedList);

  void setMicDuration(int seconds) {
    _micDuration = seconds;
    _storage.write('micDuration', seconds);
  }

  // ========== Sharing Methods ==========
  void shareResponse({required String response}) {
    Share.share(response, subject: "Check out this response!");
  }

  void copyToClipboard({required String text, required BuildContext context}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  // ========== Navigation Methods ==========
  void openChatSection() => _navigateTo(const ChatSectionPage());
  void openUserSettings() => _navigateTo(const UserSettingsPage());
  void openConnectionRequestPage() =>
      _navigateTo(const ConnectionRequestPage());
  void openPastResponses() => _navigateTo(const PastResponsesPage());
  void openFavoriteResponses() => _navigateTo(const FavouriteResponsesPage());
  void openHowToUsePage() => _navigateTo(const HowToUsePage());
  void openVoiceModelPage() => _navigateTo(const VoiceModificationPage());

  void _navigateTo(Widget page) {
    Flexify.go(
      page,
      animation: FlexifyRouteAnimations.blur,
      animationDuration: Durations.medium1,
    );
  }

  // ========== Voice Command Handling ==========
  void handleVoiceCommands(String command) {
    final lowerCommand = command.trim().toLowerCase();
    log("Attempting to handle command: '$lowerCommand'");

    // Expanded command patterns with more natural language options
    final commandPatterns = {
      'settings': ['settings', 'preferences', 'configuration', 'open settings'],
      'back': ['go back', 'exit', 'close', 'return'],
      'history': ['history', 'past queries', 'my searches', 'show history'],
      'help': ['how to use', 'help', 'instructions', 'guide'],
      'voice': [
        'voice settings',
        'voice mode',
        'change voice',
        'voice options'
      ],
      'start': [
        'start listening',
        'begin listening',
        'listen now',
        'start voice'
      ],
      'stop': [
        'stop listening',
        'end listening',
        'cancel listening',
        'stop voice'
      ],
      'speak': ['speak response', 'read answer', 'say it', 'read it'],
      'pause': ['pause speaking', 'pause voice', 'stop talking', 'pause'],
      'resume': [
        'resume speaking',
        'continue speaking',
        'keep talking',
        'continue'
      ],
      'delete': [
        'delete history',
        'clear history',
        'erase history',
        'remove history'
      ],
      'search': ['search for', 'look up', 'find', 'query', 'ask about'],
      'remaining': [
        'remaining searches',
        'searches left',
        'daily limit',
        'search count'
      ],
      'chat': ['open chat', 'go to chat', 'messages', 'conversations'],
      'favorites': ['favorites', 'saved items', 'bookmarks', 'starred'],
      'connections': ['connections', 'contacts', 'friends', 'network'],
    };

    String responseMessage = "Command not recognized";
    bool commandHandled = false;

    // Handle navigation commands
    if (_matchesAny(lowerCommand, commandPatterns['settings']!)) {
      openUserSettings();
      responseMessage = "Opening settings.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['back']!)) {
      responseMessage = "Going back to previous screen.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['history']!)) {
      openPastResponses();
      responseMessage = "Showing your search history.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['help']!)) {
      openHowToUsePage();
      responseMessage = "Opening the help guide.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['voice']!)) {
      openVoiceModelPage();
      responseMessage = "Opening voice settings.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['chat']!)) {
      openChatSection();
      responseMessage = "Opening chat section.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['favorites']!)) {
      openFavoriteResponses();
      responseMessage = "Showing your favorites.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['connections']!)) {
      openConnectionRequestPage();
      responseMessage = "Opening connections page.";
      commandHandled = true;
    }
    // Handle action commands
    else if (_matchesAny(lowerCommand, commandPatterns['start']!)) {
      startListening();
      responseMessage = "I'm listening...";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['stop']!)) {
      stopListening();
      responseMessage = "Stopped listening.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['speak']!)) {
      readOrPromptResponse();
      responseMessage = "Reading the response.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['pause']!)) {
      pauseSpeaking();
      responseMessage = "Paused speaking.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['resume']!)) {
      resumeSpeaking();
      responseMessage = "Resuming speaking.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['delete']!)) {
      deleteAllHistory();
      responseMessage = "Cleared all history.";
      commandHandled = true;
    } else if (_matchesAny(lowerCommand, commandPatterns['remaining']!)) {
      responseMessage = "You have $remainingSearchesToday searches left today.";
      commandHandled = true;
    }
    // Handle search commands
    else {
      for (var prefix in commandPatterns['search']!) {
        if (lowerCommand.startsWith(prefix)) {
          final query = lowerCommand.substring(prefix.length).trim();
          if (query.isNotEmpty) {
            _searchFieldController.text = query;
            searchYourQuery();
            responseMessage = "Searching for: $query";
            commandHandled = true;
            break;
          }
        }
      }
    }

    if (commandHandled) {
      log("Successfully handled command: '$lowerCommand'");
      _speak(responseMessage);
    } else {
      log("Unrecognized command: '$lowerCommand'");
      // Only provide feedback for substantial inputs
      if (lowerCommand.length > 5 && !_isCommonFillerWord(lowerCommand)) {
        _speak(
            "I didn't understand '$lowerCommand'. Try saying 'help' for instructions.");
      }
    }
  }

  bool _isCommonFillerWord(String input) {
    final fillers = ['uh', 'um', 'ah', 'oh', 'hmm', 'well', 'like', 'you know'];
    return fillers.contains(input.toLowerCase());
  }

  bool _looksLikeCommand(String input) {
    // Check if input starts with common command prefixes
    final commandPrefixes = [
      'open',
      'go to',
      'show',
      'start',
      'stop',
      'search',
      'find',
      'how to',
      'what is',
      'who is'
    ];

    return commandPrefixes
        .any((prefix) => input.toLowerCase().startsWith(prefix));
  }

  bool _matchesAny(String command, List<String> patterns) {
    for (var pattern in patterns) {
      if (command.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _listeningTimer?.cancel();
    _porcupineManager?.stop();
    flutterTts.stop();
    speechToText.stop();
    super.dispose();
  }
}
