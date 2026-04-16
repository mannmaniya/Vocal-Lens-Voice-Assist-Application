import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocal_lens/Model/feature_model.dart';

class HowToUseProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  int _currentIndex = 0;

  final List<FeatureModel> _features = [
    FeatureModel(
      featureId: 'install_feature',
      icon: Icons.download,
      title: 'Step 1: Install the App',
      description:
          'Download and install Vocal Lens from the Play Store or App Store.',
    ),
    FeatureModel(
      featureId: 'create_account_feature',
      icon: Icons.account_circle,
      title: 'Step 2: Create an Account',
      description:
          'Sign up using your email or Google account to unlock all features.',
    ),
    FeatureModel(
      featureId: 'login_feature',
      icon: Icons.login,
      title: 'Step 3: Log In',
      description: 'Enter your credentials and log in to get started.',
    ),
    FeatureModel(
      featureId: 'search_voice_feature',
      icon: Icons.search,
      title: 'Step 4: Search with Voice',
      description: 'Tap the microphone and speak your query to get results.',
    ),
    FeatureModel(
      featureId: 'ai_chat_feature',
      icon: Icons.chat,
      title: 'Step 5: Chat with AI',
      description:
          'Use the AI chat feature to ask questions and get intelligent responses.',
    ),
    FeatureModel(
      featureId: 'youtube_feature',
      icon: Icons.video_library,
      title: 'Step 6: YouTube Integration',
      description:
          'Search and play YouTube videos directly using voice commands.',
    ),
    FeatureModel(
      featureId: 'multi_language_feature',
      icon: Icons.language,
      title: 'Step 7: Multi-language Support',
      description:
          'Change the app language in settings for a personalized experience.',
    ),
    FeatureModel(
      featureId: 'wake_word_feature',
      icon: Icons.record_voice_over,
      title: 'Step 8: Custom Wake Word',
      description:
          'Enable custom wake words like "Hey Vocal" to activate voice commands.',
    ),
    FeatureModel(
      featureId: 'real_time_voice_feature',
      icon: Icons.hearing,
      title: 'Step 9: Real-time Voice Responses',
      description:
          'Get immediate spoken responses to your queries for a hands-free experience.',
    ),
    FeatureModel(
      featureId: 'theme_feature',
      icon: Icons.brightness_6,
      title: 'Step 10: Dark Mode and Customization',
      description:
          'Switch between light and dark themes to customize your experience.',
    ),
  ];

  HowToUseProvider() {
    _initializeTts();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      notifyListeners();
    });
  }

  List<FeatureModel> get features => _features;
  bool get isPlaying => _isPlaying;

  void togglePlayPause() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      _isPlaying = false;
    } else {
      _speakNextFeature();
    }
    notifyListeners();
  }

  void _speakNextFeature() async {
    if (_currentIndex >= _features.length) {
      _isPlaying = false;
      _currentIndex = 0; // Reset index after finishing
      notifyListeners();
      return;
    }

    _isPlaying = true;
    notifyListeners();

    await _flutterTts.speak(
      "${_features[_currentIndex].title}. ${_features[_currentIndex].description}",
    );

    _currentIndex++;
    Future.delayed(const Duration(seconds: 3), _speakNextFeature);
  }

  void speakFeature(int index) async {
    if (index >= 0 && index < _features.length) {
      await _flutterTts.speak(
        "${_features[index].title}. ${_features[index].description}",
      );
    }
  }
}
