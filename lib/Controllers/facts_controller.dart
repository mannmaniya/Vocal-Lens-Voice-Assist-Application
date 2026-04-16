import 'dart:math';
import 'package:flutter/material.dart';

class FactsController extends ChangeNotifier {
  List<String> factsAndHelps = [
    "Move the Floating Action Button (FAB) anywhere on the screen for your convenience.",
    "Just say 'Vocal' to wake up the assistant—no need to tap!",
    "Supports multiple languages, so you can interact in the language you're comfortable with.",
    "Enjoy real-time voice processing for smooth and instant responses.",
    "Customize the assistant's voice to match your preference.",
    "Let Vocal Lens read out answers with natural-sounding speech.",
    "Convert your spoken words into text effortlessly with Speech-to-Text (STT).",
    "Search and play YouTube videos using only your voice—hands-free entertainment!",
    "Ask anything, and the AI will provide intelligent answers instantly.",
    "Personalize the wake word to something unique that suits you.",
    "Modify the assistant’s voice tone and pitch for a fun experience.",
    "FAB moves dynamically—adjust it anytime for easier access.",
    "Navigate through the app using simple voice commands.",
    "Switch between dark mode and light mode for a comfortable viewing experience.",
    "View your past voice searches in the chat history anytime.",
    "Even without the internet, some basic commands will still work!",
    "The voice recognition gets better over time as you use the app.",
    "Turn AI responses on or off from the settings whenever you want.",
    "Go completely hands-free—perfect for accessibility and multitasking.",
    "Adjust speech speed and volume to match your listening preference."
  ];

  String getRandomFact() {
    final random = Random();
    return factsAndHelps[random.nextInt(factsAndHelps.length)];
  }
}
