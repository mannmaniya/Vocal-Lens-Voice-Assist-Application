import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vocal_lens/Keys/api_keys.dart';

class ImageGeneratorHelper {
  static String apiKey = ApiKeys.huggingFaceApiKey;
  static String apiUrl = ApiKeys.huggingFaceBaseUrl;

  Future<Uint8List> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"inputs": prompt}),
      );

      log("Raw Response: ${response.bodyBytes}");

      if (response.statusCode == 200) {
        // Return the raw binary image data
        return response.bodyBytes;
      } else {
        throw Exception(
            '❌ API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('⚠️ Error: $e');
    }
  }
}
