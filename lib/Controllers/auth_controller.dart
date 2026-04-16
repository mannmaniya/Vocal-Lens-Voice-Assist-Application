import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vocal_lens/Helper/auth_helper.dart';
import 'package:vocal_lens/Views/HomePage/home_page.dart';
import 'package:vocal_lens/Views/LoginPage/login_page.dart';

class AuthController extends ChangeNotifier {
  final AuthHelper _authHelper = AuthHelper();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FlutterTts _flutterTts = FlutterTts();
  User? _user;
  bool _isNotificationsEnabled = true;
  bool _isLoading = false;

  bool get isNotificationsEnabled => _isNotificationsEnabled;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  AuthController() {
    _user = FirebaseAuth.instance.currentUser;
    _initializeTts();
    checkAuth();
  }
  void toggleNotifications() {
    _isNotificationsEnabled = !_isNotificationsEnabled;
    notifyListeners();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  String getWelcomeMessage() {
    return _user != null && _user!.displayName != null
        ? "Hello ${_user!.displayName}, welcome to Vocal Lens!"
        : "Welcome to Vocal Lens!";
  }

  Future<void> speakWelcomeMessage() async {
    await _flutterTts.speak(getWelcomeMessage());
  }

  Future<void> signUpWithEmail(String email, String password) {
    return _authHelper.signUpWithEmail(email: email, password: password);
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      setLoading(true); // Start loader
      _user = await _authHelper.signInWithEmail(email, password);
      notifyListeners();
      speakWelcomeMessage();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception("Unexpected error during email sign-in: $e");
    } finally {
      setLoading(false); // Stop loader
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      setLoading(true); // Start loader

      String msg = await _authHelper.signInWithGoogle();
      log("MSG : $msg");

      if (msg == "Success") {
        Fluttertoast.showToast(
          msg: 'google_sign_in_success'.tr(),
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Flexify.goRemove(
          const HomePage(),
          animation: FlexifyRouteAnimations.blur,
          duration: Durations.medium1,
        );

        speakWelcomeMessage();
        _navigateToHomePage();
      } else {
        Fluttertoast.showToast(
          msg: 'google_sign_in_failed'.tr(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'google_sign_in_failed'.tr(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setLoading(false); // Stop loader
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _authHelper.signOut();
      _user = null;
      notifyListeners();
      _navigateToLoginPage();
    } catch (e) {
      throw Exception("Error signing out: $e");
    }
  }

  Future<void> updateDisplayName({required String displayName}) async {
    if (_user == null) throw Exception("User is not authenticated.");
    try {
      await _user!.updateDisplayName(displayName);
      await _refreshUser();
    } catch (e) {
      throw Exception("Error updating display name: $e");
    }
  }

  Future<void> updateEmail({required String email}) async {
    if (_user == null) throw Exception("User is not authenticated.");
    try {
      await _user!.verifyBeforeUpdateEmail(email);
      await _refreshUser();
    } catch (e) {
      throw Exception("Error updating email: $e");
    }
  }

  /// Refreshes the user object after updates.
  Future<void> _refreshUser() async {
    await _user!.reload();
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  /// Returns user-friendly error messages.
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password provided.";
      case 'invalid-email':
        return "Invalid email address format.";
      default:
        return "Authentication error.";
    }
  }

  void checkAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        log("No user logged in");
      } else {
        log("Logged in as: ${user.email}");
      }
    });
  }

  /// Navigates to the Home Page
  void _navigateToHomePage() {
    Flexify.goRemove(
      const HomePage(),
      animation: FlexifyRouteAnimations.blur,
      duration: Durations.medium1,
    );
  }

  /// Navigates to the Login Page
  void _navigateToLoginPage() {
    Flexify.goRemove(
      LoginPage(),
      animation: FlexifyRouteAnimations.blur,
      duration: Durations.medium1,
    );
  }
}
