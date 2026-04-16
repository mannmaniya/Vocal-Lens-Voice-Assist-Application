import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';

Widget customDrawer() {
  return Consumer<VoiceToTextController>(builder: (context, value, _) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
            ),
            child: Center(
              child: Text(
                "VocalLens Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
              color: Colors.orange,
            ),
            title: const Text(
              "Past Responses",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: value.openPastResponses,
          ),
          // ListTile(
          //   leading: const Icon(
          //     Icons.group_add,
          //     color: Colors.blue,
          //   ),
          //   title: const Text(
          //     "Connection Requests",
          //     style: TextStyle(
          //       color: Colors.white,
          //     ),
          //   ),
          //   onTap: value.openConnectionRequestPage,
          // ),
          ListTile(
            leading: const Icon(
              Icons.mic,
              color: Colors.red,
            ),
            title: const Text(
              "Voice Models",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: value.openVoiceModelPage,
          ),
          ListTile(
            leading: const Icon(
              Icons.star,
              color: Colors.purple,
            ),
            title: const Text(
              "Favorite Responses",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: value.openFavoriteResponses,
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Colors.green,
            ),
            title: const Text(
              "Settings",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: value.openUserSettings,
          ),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: Colors.lightBlue,
            ),
            title: const Text(
              "How to Use",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: value.openHowToUsePage,
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: Colors.teal,
            ),
            title: const Text(
              "Manage Permissions",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () async {
              await openAppSettings();
            },
          ),
        ],
      ),
    );
  });
}
