import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AISearchController with ChangeNotifier {
  final String apiKey;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _responses = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get responses => _responses;

  AISearchController({required this.apiKey});

  Future<void> searchQuery(String prompt) async {
    _isLoading = true;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        _responses.add({
          "question": prompt,
          "answer": response.text,
        });
      }
    } catch (e) {
      log("Error during query search: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
