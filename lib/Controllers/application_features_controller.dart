import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:vocal_lens/Views/LoginPage/login_page.dart';

class ApplicationFeaturesController extends ChangeNotifier {
  final introKey = GlobalKey<IntroductionScreenState>();
  int currentIndex = 0;

  int get getCurrentIndex => currentIndex;

  void updateIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void onIntroEnd(BuildContext context) {
    Flexify.goRemove(
       LoginPage(),
      animation: FlexifyRouteAnimations.blur,
      duration: Durations.medium1,
    );
  }

  void nextPage(BuildContext context) {
    if (currentIndex < 5) {
      introKey.currentState?.controller.animateToPage(
        currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      onIntroEnd(context);
    }
  }
}
