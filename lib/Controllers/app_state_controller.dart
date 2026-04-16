import 'package:flutter/foundation.dart';

class AppStateController with ChangeNotifier {
  bool _isRequestingPermission = false;
  int _micDuration = 5;

  bool get isRequestingPermission => _isRequestingPermission;
  int get micDuration => _micDuration;

  void setMicDuration(int seconds) {
    _micDuration = seconds;
    notifyListeners();
  }

  Future<void> requestMicrophonePermission() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;
    notifyListeners();

    // Permission handling logic

    _isRequestingPermission = false;
    notifyListeners();
  }
}
