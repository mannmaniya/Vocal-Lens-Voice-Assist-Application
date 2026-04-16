import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  final PageController pageController = PageController();

  int get selectedIndex => _selectedIndex;

  void changeItem(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void changePageView({required int index}) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigateTo(Widget page) {
    Flexify.go(
      page,
      animation: FlexifyRouteAnimations.blur,
      animationDuration: Durations.medium1,
    );
  }
}
