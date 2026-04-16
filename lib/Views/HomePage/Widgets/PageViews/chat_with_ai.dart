import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vocal_lens/Controllers/chat_with_ai_controller.dart';

Widget chatWithAIPage() {
  return Consumer<ChatWithAIController>(
    builder: (context, chatController, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: const EdgeInsets.all(20.0),
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
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (query) {
                  chatController.setSearchQuery(query);
                },
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30.0), // Rounded corners
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Colors.white30, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.6),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      chatController.setSearchQuery('');
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 10.h,
              ),
              // Display messages
              Expanded(
                child: chatController.filteredMessages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80.sp,
                              color: Colors.white24,
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Text(
                              "Start a conversation with Gemini-AI",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: chatController.filteredMessages.length +
                            (chatController.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (chatController.isLoading &&
                              index == chatController.filteredMessages.length) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 10.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0.r),
                                      topRight: Radius.circular(15.0.r),
                                      bottomLeft: Radius.zero,
                                      bottomRight: Radius.circular(15.0.r),
                                    ),
                                  ),
                                  child: SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 20.0.sp,
                                  ),
                                ),
                              ],
                            );
                          }

                          final message =
                              chatController.filteredMessages[index];
                          return Column(
                            children: [
                              if (message.containsKey('question'))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15.0.r),
                                          topRight: Radius.circular(15.0.r),
                                          bottomLeft: Radius.circular(15.0.r),
                                          bottomRight: Radius.zero,
                                        ),
                                      ),
                                      child: Text(
                                        message['question']?.toString() ??
                                            '...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (message.containsKey('answer'))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0,
                                          vertical: 10.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15.0.r),
                                            topRight: Radius.circular(15.0.r),
                                            bottomLeft: Radius.zero,
                                            bottomRight:
                                                Radius.circular(15.0.r),
                                          ),
                                        ),
                                        child: Text(
                                          message['answer']?.toString() ??
                                              '...',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
              ),
              // Input Bar
              Card(
                elevation: 5,
                color: Colors.blueGrey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: chatController.messageController,
                          decoration: const InputDecoration(
                            hintText: "Type your message...",
                            hintStyle: TextStyle(
                              color: Colors.white70,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          chatController.searchQuery();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
