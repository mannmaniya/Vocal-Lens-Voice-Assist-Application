import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

TextStyle titleTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 26.sp,
  );
}

TextStyle bodyTextStyle() {
  return TextStyle(
    fontSize: 16.sp,
    color: Colors.white,
  );
}

LottieBuilder lottieWidget({required String lottiePath}) {
  return Lottie.asset(
    lottiePath,
    height: 200.h,
  );
}
