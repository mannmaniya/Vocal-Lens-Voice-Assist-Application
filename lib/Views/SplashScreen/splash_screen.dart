import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/facts_controller.dart';
import 'package:vocal_lens/Helper/auth_helper.dart';
import 'package:vocal_lens/Views/ApplicationFeaturesPage/application_features_page.dart';
import 'package:vocal_lens/Views/HomePage/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fact = context.watch<FactsController>().getRandomFact();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      AuthHelper().getCurrentUser() != null
          ? Flexify.goRemove(
              const HomePage(),
              animation: FlexifyRouteAnimations.blur,
              duration: Durations.medium1,
            )
          : Flexify.goRemove(
              const ApplicationFeaturesPage(),
              animation: FlexifyRouteAnimations.blur,
              duration: Durations.medium1,
            );
    });
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            // Centered Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                SizedBox(
                  width: 150.w,
                  height: 150.h,
                  child: Lottie.asset(
                    "lib/Views/SplashScreen/Assets/loader.json",
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                // App Name
                Text(
                  'VocalLens',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                // Tagline
                Text(
                  'Empowering Vision through AI',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            // Fact at the Bottom
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.w,
                vertical: 20.h,
              ),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.amberAccent,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        fact,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
