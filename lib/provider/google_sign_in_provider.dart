import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;

  Future<UserCredential?> googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final u = cred.user;

      if (u == null) return cred;

      await _db.collection("users").doc(u.uid).set({
        "uid": u.uid,
        "email": u.email,
        "username": u.displayName ?? (googleUser.displayName ?? "No Name"),
        "photoUrl": u.photoURL ?? googleUser.photoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
      return cred;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> googleLogout() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }
}
