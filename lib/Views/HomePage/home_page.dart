import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/auth_controller.dart';
import 'package:vocal_lens/Controllers/navigation_controller.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/PageViews/chat_with_ai.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/PageViews/home_page_view.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/PageViews/image_generator_page_view.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/PageViews/youtube_page_view.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/appbar.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/drawer.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/fab.dart';
import 'package:vocal_lens/Views/HomePage/Widgets/navigation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();
  static const String micPermissionKey = 'has_requested_mic_permission';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      authController.speakWelcomeMessage();
    });

    _checkMicrophonePermission();
  }

  Future<void> _checkMicrophonePermission() async {
    bool hasRequestedPermission = box.read(micPermissionKey) ?? false;

    if (!hasRequestedPermission) {
      await Provider.of<VoiceToTextController>(context, listen: false)
          .ensureMicrophonePermission();
      await box.write(micPermissionKey, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navigationController, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton:
              navigationController.selectedIndex != 3 ? floatingButton() : null,
          bottomNavigationBar: navigationBar(),
          appBar: appBar(context: context),
          drawer: customDrawer(),
          body: PageView(
            controller: navigationController.pageController,
            onPageChanged: (index) {
              navigationController.changeItem(index);
            },
            children: [
              homePageView(),
              imageGeneratorPageView(),
              youTubePageView(context),
              // exploreFriendsPageView(),
              chatWithAIPage(),
            ],
          ),
        );
      },
    );
  }
}
