import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget actionButton({
  required IconData icon,
  required VoidCallback onPressed,
  required String label,
  required Color buttonColor,
  required Color textColor,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: textColor),
    label: Text(label, style: TextStyle(color: textColor)),
    style: ElevatedButton.styleFrom(
      minimumSize:  Size(160.w, 60.h),
      backgroundColor: buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
    ),
  );
}
