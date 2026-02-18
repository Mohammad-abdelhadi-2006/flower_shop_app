import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String? uid;
  String? email;
  DateTime? createdAt;
  DateTime? lastLogin;

  String? username;
  int? age;
  String? address;

  // NEW
  String? photoUrl;

  bool isLoading = false;
  String? error;

  Future<void> loadUser() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        clear();
        return;
      }

      uid = user.uid;
      email = user.email;
      createdAt = user.metadata.creationTime;
      lastLogin = user.metadata.lastSignInTime;

      final doc = await _db.collection("users").doc(user.uid).get();
      final data = doc.data();

      username = null;
      age = null;
      address = null;
      photoUrl = null; // NEW

      if (data != null) {
        username = data['username'] as String?;
        address = data['address'] as String?;
        photoUrl = data['photoUrl'] as String?; // NEW

        final a = data['age'];
        age = (a is int) ? a : (a is String ? int.tryParse(a) : null);
      }
    } catch (e) {
      error = "Something went wrong";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    uid = null;
    email = null;
    createdAt = null;
    lastLogin = null;
    username = null;
    age = null;
    address = null;
    photoUrl = null; // NEW
  }

  Future<void> updateProfile({
    required String username,
    required int age,
    required String address,
    String? photoUrl, // NEW (optional)
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      error = "No logged-in user";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        "username": username.trim(),
        "age": age,
        "address": address.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      // NEW: فقط إذا انبعت photoUrl
      if (photoUrl != null) {
        payload["photoUrl"] = photoUrl;
      }

      await _db.collection("users").doc(user.uid).set(
        payload,
        SetOptions(merge: true),
      );

      this.username = username.trim();
      this.age = age;
      this.address = address.trim();

      // NEW
      if (photoUrl != null) {
        this.photoUrl = photoUrl;
      }
    } catch (e) {
      error = "Update failed";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
