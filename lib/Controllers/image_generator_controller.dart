import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vocal_lens/Keys/api_keys.dart';

class ImageGeneratorController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Uint8List? _generatedImage;
  Uint8List? get generatedImage => _generatedImage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasValidImage =>
      _generatedImage != null && _generatedImage!.isNotEmpty;

  Future<void> generateImage(String prompt) async {
    const String apiKey = ApiKeys.imagineAiApiKey;
    const String apiUrl = 'https://api.vyro.ai/v2/image/generations';

    log('[generateImage] ✏️ Prompt: "$prompt"');

    if (prompt.trim().isEmpty) {
      _errorMessage = '⚠️ Prompt is empty.';
      log('[generateImage] $_errorMessage');
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      _generatedImage = null;
      notifyListeners();

      log('[generateImage] ⏳ Building multipart request...');
      final uri = Uri.parse(apiUrl);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $apiKey';

      request.fields['prompt'] = prompt;
      request.fields['style'] = 'realistic'; // Options: 3d, anime, cartoon...
      request.fields['aspect_ratio'] = '1:1';

      log('[generateImage] 🚀 Sending multipart/form-data request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('[generateImage] 📡 Status Code: ${response.statusCode}');

      if (response.statusCode != 200) {
        log('[generateImage] ❌ Response: ${response.body}');
        throw Exception('🔥 API failed with status: ${response.statusCode}');
      }

      // ✅ Image bytes directly in the body
      _generatedImage = response.bodyBytes;
      log('[generateImage] 🖼️ Image received: ${_generatedImage!.lengthInBytes} bytes');
    } on TimeoutException {
      _errorMessage = '⌛ Request timed out.';
      log('[generateImage] ⚠️ $_errorMessage');
    } on FormatException {
      _errorMessage = '❌ Invalid response format.';
      log('[generateImage] ⚠️ $_errorMessage');
    } on Exception catch (e) {
      _errorMessage = e.toString();
      log('[generateImage] ❌ Exception: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
      log('[generateImage] ✅ Done');
    }
  }

  void clearImage() {
    log('[ImageGeneratorController] 🧼 Clearing image and error');
    _generatedImage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
