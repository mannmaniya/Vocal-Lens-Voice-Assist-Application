import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/image_generator_controller.dart';

Widget imageGeneratorPageView() {
  TextEditingController promptController = TextEditingController();

  return Consumer<ImageGeneratorController>(
    builder: (context, imageController, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Prompt Input
              TextField(
                controller: promptController,
                onSubmitted: (value) {
                  imageController.generateImage(promptController.text);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your image prompt...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () => promptController.clear(),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              SizedBox(height: 20.h),

              // Image Display
              Expanded(
                child: Center(
                  child: imageController.isLoading
                      ? const SpinKitFadingCircle(
                          color: Colors.blue,
                          size: 50.0,
                        )
                      : imageController.hasValidImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                imageController.generatedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text(
                                        "Failed to display image",
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    color: Colors.white54, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  "Enter a prompt and generate an image!",
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                ),
              ),

              // Generate Button
              ElevatedButton(
                onPressed: promptController.text.isNotEmpty
                    ? () {
                        imageController.generateImage(promptController.text);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Generate Image"),
              ),
            ],
          ),
        ),
      );
    },
  );
}
