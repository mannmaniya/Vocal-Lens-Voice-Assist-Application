import 'package:flutter/material.dart';

class PositionController extends ChangeNotifier {
  Offset position = const Offset(0, 0);

  void updatePosition(Offset newPosition, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double x = newPosition.dx.clamp(0.0, screenWidth - 70);
    double y = newPosition.dy.clamp(0.0, screenHeight - 70);

    position = Offset(x, y);
    notifyListeners();
  }

  void resetPosition(BuildContext context) {
    double fabSize = 56.0;
    double padding = 16.0;

    double x = MediaQuery.of(context).size.width - fabSize - padding;
    double y = MediaQuery.of(context).size.height - fabSize - padding;

    position = Offset(x, y);
    notifyListeners();
  }

  void initializePosition(BuildContext context) {
    if (position == const Offset(0, 0)) {
      resetPosition(context);
    }
  }
}
