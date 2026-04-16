import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceController with ChangeNotifier {
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  final bool _isPaused = false;
  String _text = "Press the mic to start speaking...";
  String? _lastSpokenAnswer;

  // Voice settings
  String _voice = "en-us";
  double _pitch = 1.0;
  double _speechRate = 0.5;

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get text => _text;
  String? get lastSpokenAnswer => _lastSpokenAnswer;
  String get voice => _voice;
  double get pitch => _pitch;
  double get speechRate => _speechRate;

  Future<void> initialize() async {
    await flutterTts.awaitSpeakCompletion(true);
    await _initializeSpeechToText();
  }

  Future<void> _initializeSpeechToText() async {
    await speechToText.initialize();
  }
  

  Future<void> startListening() async {
    _isListening = true;
    notifyListeners();

    speechToText.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _text = result.recognizedWords;
          notifyListeners();
        }
      },
    );
  }

  void stopListening() {
    _isListening = false;
    speechToText.stop();
    notifyListeners();
  }

  Future<void> speak(String text) async {
    _isSpeaking = true;
    _lastSpokenAnswer = text;
    notifyListeners();

    await flutterTts.speak(text);
  }

  void stopSpeaking() {
    _isSpeaking = false;
    flutterTts.stop();
    notifyListeners();
  }

  void setVoice(String newVoice) {
    _voice = newVoice;
    flutterTts.setVoice({"name": newVoice, "locale": "en-US"});
    notifyListeners();
  }

  void setPitch(double newPitch) {
    _pitch = newPitch;
    flutterTts.setPitch(_pitch);
    notifyListeners();
  }

  void setSpeechRate(double newSpeechRate) {
    _speechRate = newSpeechRate;
    flutterTts.setSpeechRate(_speechRate);
    notifyListeners();
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }
}
