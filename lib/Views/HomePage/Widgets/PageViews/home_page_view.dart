import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/voice_to_text.dart';
import 'package:vocal_lens/Views/DetailedResponsePage/detailed_response_pages.dart';

Widget homePageView() {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 20.0,
      vertical: 20.0,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blueGrey.shade900,
          Colors.black,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Consumer<VoiceToTextController>(builder: (context, value, _) {
      final remainingSearches = value.remainingSearchesToday;
      final isLimitWarning = remainingSearches <= 1;

      return SingleChildScrollView(
        child: Column(
          children: [
            // Search limit indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isLimitWarning
                    ? Colors.red.shade900
                    : Colors.blueGrey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLimitWarning)
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade300, size: 16.sp),
                  if (isLimitWarning) SizedBox(width: 8.w),
                  Text(
                    'Searches: $remainingSearches/${VoiceToTextController.dailySearchLimit}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),

            Card(
              elevation: 5,
              color: Colors.blueGrey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: value.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        value.text,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Card(
              elevation: 5,
              color: Colors.blueGrey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter your Query:",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: value.searchFieldController,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade900,
                              hintText: "Type your query here",
                              hintStyle: const TextStyle(
                                color: Colors.white54,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.cyan,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                onPressed: value.searchFieldController.clear,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        ElevatedButton(
                          onPressed: value.isButtonEnabled &&
                                  remainingSearches > 0
                              ? () {
                                  if (remainingSearches > 0) {
                                    value.searchYourQuery();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Daily search limit reached'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: remainingSearches > 0
                                ? Colors.cyan
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Search",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isLimitWarning)
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          remainingSearches == 0
                              ? 'You have reached your daily search limit'
                              : 'Only $remainingSearches search${remainingSearches == 1 ? '' : 's'} left',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            // Responses Section
            SizedBox(
              height: 350.h,
              child: Card(
                elevation: 5,
                color: Colors.blueGrey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Response",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 68.w,
                          ),
                          IconButton(
                            onPressed: () {
                              if (value.responses.isNotEmpty) {
                                value.readOrPromptResponse();
                              } else {
                                value.readOrPromptResponse();
                              }
                            },
                            icon: const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (value.isSpeaking) {
                                value.stopSpeaking();
                              } else {
                                value.resumeSpeaking();
                              }
                            },
                            icon: Icon(
                              value.isSpeaking ? Icons.stop : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                          Visibility(
                            visible: value.responses.isNotEmpty &&
                                value.responses[0]['answer'] != null &&
                                value.responses[0]['answer'].isNotEmpty,
                            child: IconButton(
                              onPressed: () {
                                Flexify.go(
                                  DetailedResponsePages(
                                    question: value.responses[0]['question'],
                                    answer: value.responses[0]['answer'],
                                  ),
                                  animation: FlexifyRouteAnimations.blur,
                                  animationDuration: Durations.medium1,
                                );
                              },
                              icon: const Icon(
                                Icons.open_in_full,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: value.responses.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              color: Colors.grey.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Que. ${value.responses[index]['question']}",
                                      style: TextStyle(
                                        fontSize: 16.h,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyan,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    Text(
                                      "Ans:\n${value.responses[index]['answer']}",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );
}
