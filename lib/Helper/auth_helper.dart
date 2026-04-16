import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createUserDocument(userCredential.user!);
      return userCredential.user;
    } catch (e) {
      throw Exception("Error signing in with email: $e");
    }
  }

  // Sign in with Google
  Future<String> signInWithGoogle() async {
    String msg = "";
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        await _createUserDocument(userCredential.user!);

        msg = "Success";
      }
    } on FirebaseAuthException catch (e) {
      msg = e.code;
    }

    return msg;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Create or update user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    // final docSnapshot = await userRef.get();

    // if (!docSnapshot.exists) {

    // }

    await userRef.set({
      'uid': user.uid,
      'username': user.displayName ?? 'Unnamed',
      'email': user.email,
      'profile_picture': user.photoURL ?? '',
      'connections': []
    });
  }

  // Fetch all registered users except the current user
  Future<List<String>> getAllUsers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No user is logged in.");
      }

      final usersSnapshot = await _firestore.collection('users').get();

      List<String> users = [];
      for (var doc in usersSnapshot.docs) {
        log("User found: ${doc.data()}"); // Debugging
        if (doc.id != currentUser.uid) {
          users.add(doc.data()['username'].toString());
        }
      }

      log("Fetched users: $users");
      return users;
    } catch (e) {
      log("Error fetching users: $e");
      throw Exception("Error fetching users: $e");
    }
  }

  Future<void> signUpWithEmail(
      {required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _createUserDocument(userCredential.user!);
    } catch (e) {
      throw Exception("Error signing up with email: $e");
    }
  }

  Future<bool> hasSentRequest(String userName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final querySnapshot = await _firestore
          .collection('connection_requests')
          .where('sender', isEqualTo: currentUser.uid)
          .where('receiver', isEqualTo: userName)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Error checking request status: $e");
    }
  }

  Future<void> acceptConnectionByUserName(String userName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final querySnapshot = await _firestore
          .collection('connection_requests')
          .where('receiver', isEqualTo: currentUser.uid)
          .where('sender', isEqualTo: userName)
          .where('status', isEqualTo: 'pending')
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No pending request found from $userName.");
      }

      final requestDoc = querySnapshot.docs.first;

      await requestDoc.reference.update({'status': 'accepted'});

      await _firestore.collection('connections').doc(currentUser.uid).set({
        'accepted': FieldValue.arrayUnion([userName]),
      }, SetOptions(merge: true));

      final senderSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: userName)
          .get();

      if (senderSnapshot.docs.isNotEmpty) {
        final senderId = senderSnapshot.docs.first.id;
        await _firestore.collection('connections').doc(senderId).set({
          'accepted': FieldValue.arrayUnion([currentUser.displayName]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception("Error accepting connection from $userName: $e");
    }
  }

  Future<void> rejectConnectionByUserName(String userName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final querySnapshot = await _firestore
          .collection('connection_requests')
          .where('receiver', isEqualTo: currentUser.uid)
          .where('sender', isEqualTo: userName)
          .where('status', isEqualTo: 'pending')
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No pending request found from $userName.");
      }

      final requestDoc = querySnapshot.docs.first;
      await requestDoc.reference.update({'status': 'rejected'});
    } catch (e) {
      throw Exception("Error rejecting connection from $userName: $e");
    }
  }

  // Send a connection request
  Future<void> sendConnectionRequest(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in.");

    await _firestore.collection('connection_requests').add({
      'sender': currentUser.uid,
      'receiver': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get received connection requests
  Future<List<Map<String, dynamic>>> getConnectionRequests() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in.");

    final querySnapshot = await _firestore
        .collection('connection_requests')
        .where('receiver', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Accept a connection request
  Future<void> acceptConnection(String senderId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in.");

    final querySnapshot = await _firestore
        .collection('connection_requests')
        .where('receiver', isEqualTo: currentUser.uid)
        .where('sender', isEqualTo: senderId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No pending request found from this user.");
    }

    final requestDoc = querySnapshot.docs.first;
    await requestDoc.reference.update({'status': 'accepted'});

    await _firestore.collection('connections').doc(currentUser.uid).set({
      'accepted': FieldValue.arrayUnion([senderId]),
    }, SetOptions(merge: true));

    await _firestore.collection('connections').doc(senderId).set({
      'accepted': FieldValue.arrayUnion([currentUser.uid]),
    }, SetOptions(merge: true));
  }

  // Reject a connection request
  Future<void> rejectConnection(String senderId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in.");

    final querySnapshot = await _firestore
        .collection('connection_requests')
        .where('receiver', isEqualTo: currentUser.uid)
        .where('sender', isEqualTo: senderId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (querySnapshot.docs.isEmpty) return;

    final requestDoc = querySnapshot.docs.first;
    await requestDoc.reference.delete();
  }

  // Get list of accepted connections
  Future<List<String>> getAcceptedConnections() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in.");

    final docSnapshot =
        await _firestore.collection('connections').doc(currentUser.uid).get();
    if (docSnapshot.exists) {
      return List<String>.from(docSnapshot.data()?['accepted'] ?? []);
    }
    return [];
  }

  // Remove a connection
  Future<void> removeConnection(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in.");

    await _firestore.collection('connections').doc(currentUser.uid).update({
      'accepted': FieldValue.arrayRemove([userId]),
    });

    await _firestore.collection('connections').doc(userId).update({
      'accepted': FieldValue.arrayRemove([currentUser.uid]),
    });
  }
}
