import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/application_features_controller.dart';
import 'package:vocal_lens/Views/ApplicationFeaturesPage/Widgets/normal_widgets.dart';

class ApplicationFeaturesPage extends StatelessWidget {
  const ApplicationFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 19.sp,
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      pageColor: Colors.black,
      imagePadding: EdgeInsets.zero,
    );

    return SafeArea(
      child: Consumer<ApplicationFeaturesController>(
        builder: (context, value, _) {
          return Scaffold(
            body: IntroductionScreen(
              key: value.introKey,
              globalBackgroundColor: Colors.black,
              pages: [
                PageViewModel(
                  image: lottieWidget(
                    lottiePath:
                        "lib/Views/ApplicationFeaturesPage/Assets/loader_1.json",
                  ),
                  titleWidget: Center(
                    child: Text(
                      "Welcome to VocalLens",
                      style: titleTextStyle(),
                    ),
                  ),
                  bodyWidget: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Discover how to make the most of our app",
                          style: bodyTextStyle(),
                        ),
                      ],
                    ),
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  image: lottieWidget(
                    lottiePath:
                        "lib/Views/ApplicationFeaturesPage/Assets/ai_loader.json",
                  ),
                  titleWidget: Center(
                    child: Text(
                      "Chat and Interact with AI",
                      style: titleTextStyle(),
                    ),
                  ),
                  bodyWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Engage in seamless conversations with AI,",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "and receive spoken responses instantly.",
                        style: bodyTextStyle(),
                      ),
                    ],
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  image: lottieWidget(
                    lottiePath:
                        "lib/Views/ApplicationFeaturesPage/Assets/youtube_loader.json",
                  ),
                  titleWidget: Center(
                    child: Text(
                      "Seamless Video Streaming",
                      style: titleTextStyle(),
                    ),
                  ),
                  bodyWidget: Column(
                    children: [
                      Text(
                        "Discover how to watch your favorite",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "YouTube videos directly on VocalLens!",
                        style: bodyTextStyle(),
                      ),
                    ],
                  ),
                  decoration: pageDecoration,
                ),
                // PageViewModel(
                //   image: lottieWidget(
                //     lottiePath:
                //         "lib/Views/ApplicationFeaturesPage/Assets/loader_3.json",
                //   ),
                //   titleWidget: Center(
                //     child: Text(
                //       "Explore New Friends",
                //       style: titleTextStyle(),
                //     ),
                //   ),
                //   bodyWidget: Column(
                //     children: [
                //       Text(
                //         "Discover and connect with new friends on",
                //         style: bodyTextStyle(),
                //       ),
                //       Text(
                //         "VocalLens, just like on social media!",
                //         style: bodyTextStyle(),
                //       ),
                //     ],
                //   ),
                //   decoration: pageDecoration,
                // ),
                PageViewModel(
                  image: lottieWidget(
                    lottiePath:
                        "lib/Views/ApplicationFeaturesPage/Assets/voice_loader.json",
                  ),
                  titleWidget: Center(
                    child: Text(
                      "Voice Commands",
                      style: titleTextStyle(),
                    ),
                  ),
                  bodyWidget: Column(
                    children: [
                      Text(
                        "Control the app effortlessly with minimal",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "touch interaction, using only voice",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "commands.",
                        style: bodyTextStyle(),
                      ),
                    ],
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  image: lottieWidget(
                    lottiePath:
                        "lib/Views/ApplicationFeaturesPage/Assets/final_loader.json",
                  ),
                  titleWidget: Center(
                    child: Text(
                      "Enjoy the Experience",
                      style: titleTextStyle(),
                    ),
                  ),
                  bodyWidget: Column(
                    children: [
                      Text(
                        "You're all set! While this is the final slide,",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "VocalLens offers many more exciting",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "features waiting for you to explore. Enjoy",
                        style: bodyTextStyle(),
                      ),
                      Text(
                        "the journey!",
                        style: bodyTextStyle(),
                      ),
                    ],
                  ),
                  decoration: pageDecoration,
                ),
              ],
              onDone: () => value.onIntroEnd(context),
              showSkipButton: false,
              showNextButton: false,
              showDoneButton: false,
              onChange: (index) {
                value.updateIndex(index);
              },
              globalFooter: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => value.onIntroEnd(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Skip"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        value.nextPage(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        value.getCurrentIndex == 5 ? "Get Started" : "Next",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
