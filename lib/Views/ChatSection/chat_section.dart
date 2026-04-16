import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/chat_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vocal_lens/Views/UserChat/user_chat.dart';

class ChatSectionPage extends StatelessWidget {
  const ChatSectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        foregroundColor: Colors.white,
        title: Text(
          tr('chat_section'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: chatController.getUserChatRooms(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blueGrey),
              );
            }

            var chatRooms = snapshot.data!.docs;

            if (chatRooms.isEmpty) {
              return Center(
                child: Text(
                  tr('no_users_found'),
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              );
            }

            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                var chatRoom = chatRooms[index].data() as Map<String, dynamic>;
                String chatRoomId = chatRooms[index].id;
                List users = chatRoom['users'];

                // ✅ Identify the other user
                String receiverId = users.firstWhere(
                  (user) => user != chatController.currentUserId,
                );

                return FutureBuilder<DocumentSnapshot>(
                  future: chatController.getUserDetails(receiverId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox.shrink();

                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    String userName = userData['name'] ?? "Unknown User";
                    String lastMessage =
                        chatRoom['lastMessage'] ?? "Start a conversation";

                    return Card(
                      elevation: 5,
                      color: Colors.blueGrey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          radius: 30.r,
                          backgroundImage: NetworkImage(
                            userData['profilePic'] ??
                                'https://img.freepik.com/free-psd/contact-icon-illustration-isolated_23-2151903337.jpg',
                          ),
                        ),
                        title: Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: const Icon(Icons.chat, color: Colors.white),
                        onTap: () {
                          // ✅ Pass correct chat room data
                          Flexify.go(
                            UserChatPage(
                              chatRoomId: chatRoomId,
                              receiverId: receiverId,
                              receiverName: userName,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
