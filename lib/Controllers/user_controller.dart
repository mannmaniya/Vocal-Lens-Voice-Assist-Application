import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocal_lens/Helper/auth_helper.dart';

class UserController extends ChangeNotifier {
  final AuthHelper _authHelper = AuthHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> allUsers = [];
  List<String> filteredUsers = [];
  List<String> sentRequests = [];
  List<Map<String, dynamic>> receivedRequests = [];
  List<String> connections = [];

  UserController() {
    listenToUsers();
  }

  void listenToUsers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      allUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return data.containsKey('username')
            ? data['username'] as String
            : "Unnamed";
      }).toList();

      filteredUsers = List.from(allUsers);
      log("Updated users: $allUsers");
      notifyListeners();
    });
  }

  void filterUsers(String query) {
    filteredUsers = allUsers
        .where((user) => user.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    try {
      allUsers = await _authHelper.getAllUsers();
      filteredUsers = List.from(allUsers);
      notifyListeners();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<void> debugFetchAllUsers() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final users = usersSnapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        'username': doc.data()['username'],
      };
    }).toList();
    log("📋 All Firestore Users: $users");
  }

  Future<String?> getUserUidByName(String userName) async {
    final trimmedUserName = userName.trim().toLowerCase();
    try {
      log("🔍 Searching UID for username: '$trimmedUserName'");

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username_lower',
              isEqualTo: trimmedUserName) // 👈 Query lowercase field
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final uid = querySnapshot.docs.first.id;
        log("✅ Found UID for '$trimmedUserName': $uid");
        return uid;
      } else {
        log("⚠️ No UID found for username: '$trimmedUserName'");
      }
    } catch (e) {
      log("❌ Error fetching UID for '$trimmedUserName': $e");
    }
    return null;
  }

  Future<void> sendConnectionRequest(String recipientId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      log("❌ Error: User not authenticated.");
      return;
    }

    final connectionRequest = {
      'from': currentUser.uid, // ✅ Store UID instead of username
      'to': recipientId, // ✅ Use recipient UID
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    log("📤 Sending connection request: $connectionRequest");

    try {
      await FirebaseFirestore.instance
          .collection('connection_requests')
          .add(connectionRequest);
      log("✅ Connection request sent successfully!");
    } catch (e) {
      log("❌ Firestore Error: $e");
    }
  }

  Future<bool> hasSentRequest(String userName) async {
    try {
      return await _authHelper.hasSentRequest(userName);
    } catch (e) {
      throw Exception("Error checking connection request status: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getConnectionRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      log("❌ Error: User not authenticated.");
      return [];
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('connection_requests')
          .where('to', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final requests = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'sender': doc['from'],
        };
      }).toList();

      log("📥 Connection Requests Fetched: $requests");
      return requests;
    } catch (e) {
      log("❌ Firestore Error fetching connection requests: $e");
      return [];
    }
  }

  Future<void> fetchConnectionRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      log("❌ User not authenticated.");
      return;
    }

    log("🆔 Fetching requests for user: ${currentUser.uid}");

    try {
      // 🔍 Step 1: Fetch connection requests for the current user
      final snapshot = await FirebaseFirestore.instance
          .collection('connection_requests')
          .where('to', isEqualTo: currentUser.uid) // ✅ Ensure UID is used
          .where('status', isEqualTo: 'pending')
          .get();

      receivedRequests = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'from': doc['from'],
        };
      }).toList();

      log("✅ Processed Requests: $receivedRequests");

      // ❗ If no requests found, debug by fetching all connection requests
      if (receivedRequests.isEmpty) {
        log("⚠️ No requests found. Fetching all requests for debugging...");

        final debugSnapshot = await FirebaseFirestore.instance
            .collection('connection_requests')
            .get();

        log("🔍 All Requests in Firestore: ${debugSnapshot.docs.map((doc) => doc.data()).toList()}");
      }

      notifyListeners();
    } catch (e) {
      log("❌ Firestore Error fetching connection requests: $e");
    }
  }

  /// Accept a connection request
  Future<void> acceptRequest(String senderUid) async {
    try {
      // Update request status to "accepted"
      QuerySnapshot querySnapshot = await _firestore
          .collection('connection_requests')
          .where('from', isEqualTo: senderUid)
          .where('to',
              isEqualTo:
                  'your_current_user_uid') // Replace with actual UID fetching logic
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore
            .collection('connection_requests')
            .doc(doc.id)
            .update({'status': 'accepted'});
      }

      // Add to connections list
      await _firestore.collection('connections').add({
        'user1': 'your_current_user_uid',
        'user2': senderUid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Refresh data
      fetchConnectionRequests();
    } catch (e) {
      debugPrint("Error accepting request: $e");
    }
  }

  /// Get username from UID
  Future<String> getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['username'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      debugPrint("Error fetching username: $e");
      return 'Unknown';
    }
  }

  /// Reject a connection request
  Future<void> rejectRequest(String senderUid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('connection_requests')
          .where('from', isEqualTo: senderUid)
          .where(
            'to',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore.collection('connection_requests').doc(doc.id).delete();
      }

      // Refresh data
      fetchConnectionRequests();
    } catch (e) {
      debugPrint("Error rejecting request: $e");
    }
  }
}
