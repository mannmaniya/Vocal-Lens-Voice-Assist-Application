# 🎙️ Vocal Lens - AI Voice Assistant

Vocal Lens is a sophisticated AI-powered voice assistant application built with Flutter. It combines cutting-edge AI technologies to provide a seamless, hands-free experience for users, featuring everything from local AI conversations and cloud-based image generation to voice-controlled YouTube streaming.

---

## ✨ Key Features

### 🎙️ Intelligent Voice Interface
- **Wake Word Detection**: Activate the assistant hands-free with "Vocal Lens" powered by **Picovoice Porcupine**.
- **Voice Commands**: Effortlessly control navigation and app features using natural speech.
- **Advanced STT/TTS**: High-quality Speech-to-Text and Text-to-Speech for natural, fluid interactions.
- **Voice Customization**: Adjust pitch and speech rate to personalize your assistant's voice.

### 🤖 AI-Powered Capabilities
- **On-Device AI Chat**: Engage in private, offline conversations powered by **Google Gemma (1B IT)** running locally on your device.
- **Cloud AI Search**: Get instant, accurate answers to complex queries using **Google Gemini 1.5 Pro**.
- **AI Image Generation**: Create stunning realistic visuals from text prompts using the **Vyro.ai (Imagine AI)** engine.
- **Contextual Intelligence**: Intelligent search controllers that understand and process user intent.

### 🎥 Media & Social
- **YouTube Voice Integration**: Search, play, and control YouTube videos entirely by voice.
- **Audio Downloading**: Extract and save audio from YouTube videos directly to your device.
- **Social Connections**: Find other users, send connection requests, and build your AI-assisted network via Firebase.
- **Interaction History**: Keep track of your past queries, favorite responses, and pinned interactions.

### 🛠️ Developer-First Features
- **Multi-language Support**: Fully localized with dedicated assets for English, Hindi, Spanish, French, German, and Dutch.
- **Robust State Management**: Built on the **Provider** pattern for efficient and scalable state handling.
- **Modern UI/UX**: Feature-rich interface with Lottie animations, draggable action buttons, and full dark/light mode support.
- **Cross-Platform Foundation**: Designed for high performance across mobile platforms.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend & Auth**: [Firebase](https://firebase.google.com/) (Authentication, Firestore, Storage)
- **AI Engines**:
  - **Local AI**: [Google Gemma](https://huggingface.co/google/gemma-7b) via `flutter_gemma`
  - **Cloud AI**: [Google Gemini 1.5 Pro](https://ai.google.dev/)
  - **Image Gen**: [Vyro.ai Imagine API](https://www.imagine.art/api)
- **Voice Stack**:
  - **Wake Word**: [Picovoice Porcupine](https://picovoice.ai/platform/porcupine/)
  - **STT**: [Speech To Text](https://pub.dev/packages/speech_to_text)
  - **TTS**: [Flutter TTS](https://pub.dev/packages/flutter_tts)
- **Media**: [YouTube Player Flutter](https://pub.dev/packages/youtube_player_flutter) & [Youtube Explode](https://pub.dev/packages/youtube_explode_dart)
- **Storage**: [GetStorage](https://pub.dev/packages/get_storage) for lightweight persistence.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.5.4 or higher)
- Firebase project configured for Android/iOS
- API Keys for the following services:
  - Google AI (Gemini)
  - YouTube Data API v3
  - Picovoice (AccessKey)
  - Vyro.ai (Imagine AI API Key)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mannmaniya/Vocal-Lens-Voice-Assist-Application.git
   cd Vocal-Lens-Voice-Assist-Application
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective platform directories.
   - Enable Authentication and Firestore in the Firebase Console.

---

## ⚙️ Configuration & Environment Variables

Vocal Lens uses `--dart-define` for secure API key management. This prevents sensitive keys from being hardcoded in the source.

### Available Keys:
- `GEMINI_API_KEY`
- `YOUTUBE_API_KEY`
- `HUGGING_FACE_API_KEY`
- `PICOVOICE_API_KEY`
- `IMAGINE_AI_API_KEY`

### Running the App:
```bash
flutter run \
  --dart-define=GEMINI_API_KEY=YOUR_KEY \
  --dart-define=YOUTUBE_API_KEY=YOUR_KEY \
  --dart-define=HUGGING_FACE_API_KEY=YOUR_KEY \
  --dart-define=PICOVOICE_API_KEY=YOUR_KEY \
  --dart-define=IMAGINE_AI_API_KEY=YOUR_KEY
```

---

## 🏗 Project Architecture

The codebase follows a modular, controller-based architecture:

- **lib/Controllers/**: Main business logic (Voice, Chat, YouTube, AI Search, etc.).
- **lib/Views/**: UI layers organized by feature (Chat, Home, YouTube Player, etc.).
- **lib/Helper/**: Utility classes for API interactions and authentication.
- **lib/Model/**: Data structures for messages, users, and features.
- **lib/Assets/**: Localization files (JSON) and animation assets.

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository.
2. **Create** your feature branch (`git checkout -b feature/NewFeature`).
3. **Commit** your changes (`git commit -m 'Add NewFeature'`).
4. **Push** to the branch (`git push origin feature/NewFeature`).
5. **Open** a Pull Request.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📬 Contact

**Mann Maniya** - [LinkedIn](https://www.linkedin.com/in/mann-maniya-77a8b5367) - mannmaniya7@gmail.com

Project Link: [https://github.com/mannmaniya/Vocal-Lens-Voice-Assist-Application](https://github.com/mannmaniya/Vocal-Lens-Voice-Assist-Application)

---

Give a ⭐ if you liked this project!
