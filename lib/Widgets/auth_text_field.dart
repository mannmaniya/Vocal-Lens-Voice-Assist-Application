import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget buildTextFormField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isPassword = false,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    style: const TextStyle(
      color: Colors.white,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white70,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.white,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.white70,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade800,
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return '${label}_required'.tr();
      }
      return null;
    },
  );
}
