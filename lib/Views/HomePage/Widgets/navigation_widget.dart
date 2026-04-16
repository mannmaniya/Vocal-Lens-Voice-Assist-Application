import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/navigation_controller.dart';

Widget navigationBar() {
  return Consumer<NavigationController>(builder: (context, value, _) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12.0.sp,
            color: Colors.white,
          ),
        ),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      child: NavigationBar(
        elevation: 3,
        selectedIndex: value.selectedIndex,
        onDestinationSelected: (index) {
          value.changeItem(index);
          value.changePageView(index: index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            label: "Home",
            icon: Icon(
              CupertinoIcons.square_favorites,
              color: Colors.blueAccent,
            ),
          ),
          NavigationDestination(
            label: "Image Gen",
            icon: Icon(
              Icons.auto_awesome,
              color: Colors.green,
            ),
          ),
          NavigationDestination(
            label: "Youtube",
            icon: FaIcon(
              FontAwesomeIcons.youtube,
              color: Colors.red,
            ),
          ),
          // NavigationDestination(
          //   label: "Discover",
          //   icon: Icon(
          //     Icons.group_add,
          //     color: Colors.cyan,
          //   ),
          // ),
          NavigationDestination(
            label: "AI-Assist",
            icon: Icon(
              Icons.memory,
              color: Colors.orange,
            ),
          ),
        ],
        backgroundColor: Colors.grey.shade800,
        indicatorColor: Colors.grey.shade500,
      ),
    );
  });
}
