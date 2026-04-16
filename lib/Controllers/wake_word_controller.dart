import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

class WakeWordController with ChangeNotifier {
  PorcupineManager? _porcupineManager;
  bool _isWakeWordActive = true;

  bool get isWakeWordActive => _isWakeWordActive;

  Future<void> initialize(String apiKey) async {
    _porcupineManager = await PorcupineManager.fromKeywordPaths(
      apiKey,
      ["Assets/Vocal_en_android_v3_0_0.ppn"],
      _onWakeWordDetected,
    );
    await _porcupineManager?.start();
  }

  void _onWakeWordDetected(int keywordIndex) {
    log("Wake word detected!");
    notifyListeners();
  }

  Future<void> toggleWakeWordDetection() async {
    if (_isWakeWordActive) {
      await _porcupineManager?.stop();
    } else {
      await _porcupineManager?.start();
    }
    _isWakeWordActive = !_isWakeWordActive;
    notifyListeners();
  }

  @override
  void dispose() {
    _porcupineManager?.stop();
    super.dispose();
  }
}
