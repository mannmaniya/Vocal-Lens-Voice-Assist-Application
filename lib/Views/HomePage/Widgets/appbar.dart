import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/position_controller.dart';

PreferredSizeWidget appBar({required BuildContext context}) {
  return AppBar(
    foregroundColor: Colors.white,
    title: Text(
      "VocalLens",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.black,
    actions: [
      IconButton(
        icon: const FaIcon(
          FontAwesomeIcons.locationCrosshairs,
        ),
        onPressed: () {
          Provider.of<PositionController>(
            context,
            listen: false,
          ).resetPosition(context);
        },
        color: Colors.white,
      ),
      // IconButton(
      //   icon: const FaIcon(
      //     FontAwesomeIcons.commentDots,
      //   ),
      //   onPressed: Provider.of<VoiceToTextController>(
      //     context,
      //     listen: false,
      //   ).openChatSection,
      //   color: Colors.white,
      // ),
    ],
  );
}
