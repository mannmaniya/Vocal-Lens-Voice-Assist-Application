import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vocal_lens/Controllers/application_features_controller.dart';
import 'package:vocal_lens/Controllers/auth_controller.dart';
import 'package:vocal_lens/Controllers/chat_controller.dart';
import 'package:vocal_lens/Controllers/chat_with_ai_controller.dart';
import 'package:vocal_lens/Controllers/facts_controller.dart';
import 'package:vocal_lens/Controllers/how_to_use_controller.dart';
import 'package:vocal_lens/Controllers/image_generator_controller.dart';
import 'package:vocal_lens/Controllers/navigation_controller.dart';
import 'package:vocal_lens/Controllers/position_controller.dart';
import 'package:vocal_lens/Controllers/theme_controller.dart';
import 'package:vocal_lens/Controllers/user_controller.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';
import 'package:vocal_lens/Controllers/youtube_controller.dart';
import 'package:vocal_lens/Views/SplashScreen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => VoiceToTextController(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatController(),
        ),
        ChangeNotifierProvider(
          create: (context) => FactsController(),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageGeneratorController(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeController(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(),
        ),
        ChangeNotifierProvider(
          create: (context) => NavigationController(),
        ),
        ChangeNotifierProvider(
          create: (context) => YoutubeController(),
        ),
        ChangeNotifierProvider(
          create: (context) => HowToUseProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final controller = PositionController();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.initializePosition(context);
            });
            return controller;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => ChatWithAIController()..initializeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserController(),
        ),
        ChangeNotifierProvider(
          create: (context) => ApplicationFeaturesController(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: Size(width, height),
        minTextAdapt: true,
        builder: (context, _) {
          return Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return Flexify(
                designWidth: width,
                designHeight: height,
                app: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  themeMode: themeController.isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: const SplashScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
