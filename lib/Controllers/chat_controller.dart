import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // 🔹 Get Messages (Real-time)
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 🔹 Send a Message
  Future<void> sendMessage(String chatRoomId, String message) async {
    String senderId = currentUserId!;

    await _firestore
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Messages')
        .add({
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update Last Message in Chat Room
    await _firestore.collection('ChatRoom').doc(chatRoomId).update({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Create Chat Room (if not exists)
  Future<String> createChatRoom(String userId, String receiverId) async {
    List<String> userIds = [userId, receiverId]
      ..sort(); // Ensures unique room ID
    String chatRoomId = "${userIds[0]}_${userIds[1]}";

    DocumentSnapshot chatRoom =
        await _firestore.collection('ChatRoom').doc(chatRoomId).get();

    if (!chatRoom.exists) {
      await _firestore.collection('ChatRoom').doc(chatRoomId).set({
        'users': userIds,
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  Stream<QuerySnapshot> getUserChatRooms() {
    return _firestore
        .collection('ChatRoom')
        .where('users',
            arrayContains: currentUserId) // Only fetch relevant chat rooms
        .snapshots();
  }

  // ✅ Fetch user details from Firestore
  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
}
