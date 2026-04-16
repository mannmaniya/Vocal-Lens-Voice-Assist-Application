import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/user_controller.dart';
import 'package:vocal_lens/Views/UserChat/user_chat.dart';

Widget exploreFriendsPageView() {
  return Consumer<UserController>(
    builder: (context, controller, _) {
      final TextEditingController searchController = TextEditingController();
      final Random random = Random();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 SEARCH FIELD
            Card(
              elevation: 3,
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (query) => controller.filterUsers(query),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    hintText: "Search users...",
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        searchController.clear();
                        controller.filterUsers('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // 🔹 USERS GRID VIEW
            Expanded(
              child: controller.filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        "No users found",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: controller.filteredUsers.length,
                      itemBuilder: (context, index) {
                        String user = controller.filteredUsers[index];
                        Color profileColor = Color.fromRGBO(
                          150 + random.nextInt(106),
                          150 + random.nextInt(106),
                          150 + random.nextInt(106),
                          1,
                        );

                        return Card(
                          color: Colors.grey.shade900,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35.sp,
                                  backgroundColor: profileColor,
                                  child: Text(
                                    user[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  user,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),

                                // 🔹 CHAT BUTTON
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserChatPage(
                                          chatRoomId: "chat_room_id_$user",
                                          receiverId: "receiver_id_$user",
                                          receiverName: user,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Chat Now",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
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
      );
    },
  );
}
