// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flower_shop_app/pages/login.dart';
import 'package:flower_shop_app/shared/colors.dart';
import 'package:flower_shop_app/shared/contants.dart';
import 'package:flower_shop_app/shared/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool ShwoPass = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();

  bool isPassword8Char = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() {
        _avatarFile = File(picked.path);
      });
    } catch (e) {
      showSnackBar(context, "Failed to pick image: $e");
    }
  }

  Future<String?> _uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = FirebaseStorage.instance.ref().child("users/$uid/$fileName");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  void onPasswordChanged(String password) {
    setState(() {
      isPassword8Char = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> register() async {
    setState(() => isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        showSnackBar(context, "Failed to create account");
        setState(() => isLoading = false);
        return;
      }

      String? photoUrl;
      if (_avatarFile != null) {
        photoUrl = await _uploadAvatar(uid: user.uid, file: _avatarFile!);
      }

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "age": int.parse(ageController.text.trim()),
        "address": addressController.text.trim(),
        "photoUrl": photoUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      showSnackBar(context, "Account created successfully");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, "Weak password");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, "Email already exists");
      } else if (e.code == 'invalid-email') {
        showSnackBar(context, "Invalid email");
      } else {
        showSnackBar(context, "Auth error: ${e.message}");
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, "Firestore/Storage error: ${e.message}");
    } catch (e) {
      showSnackBar(context, "Error: $e");
    }

    setState(() => isLoading = false);
  }

  Widget buildCheck(String text, bool condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            condition ? Icons.check_circle : Icons.radio_button_unchecked,
            color: condition ? Colors.green : Colors.grey,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: condition ? Colors.green : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F6F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /// AVATAR (NEW)
                  GestureDetector(
                    onTap: isLoading ? null : _pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: appbarGreen.withOpacity(0.12),
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : null,
                          child: _avatarFile == null
                              ? Icon(Icons.person, size: 44, color: appbarGreen)
                              : null,
                        ),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: btnGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  /// TITLE
                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Register to continue",
                    style: TextStyle(color: Colors.grey),
                  ),

                  SizedBox(height: 30),

                  /// USERNAME
                  TextFormField(
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Username required";
                      }
                      return null;
                    },
                    decoration: decorationTextfield.copyWith(
                      prefixIcon: Icon(Icons.person),
                      hintText: "Username",
                    ),
                  ),

                  SizedBox(height: 15),

                  /// AGE
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Age is required";
                      }
                      final age = int.tryParse(value.trim());
                      if (age == null) return "Enter valid number";
                      if (age < 12) return "Too young";
                      if (age > 100) return "Invalid age";
                      return null;
                    },
                    decoration: decorationTextfield.copyWith(
                      prefixIcon: Icon(Icons.cake),
                      hintText: "Age",
                    ),
                  ),

                  SizedBox(height: 15),

                  /// ADDRESS
                  TextFormField(
                    controller: addressController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Address is required";
                      }
                      return null;
                    },
                    decoration: decorationTextfield.copyWith(
                      prefixIcon: Icon(Icons.location_on),
                      hintText: "Address",
                    ),
                  ),

                  SizedBox(height: 15),

                  /// EMAIL
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }

                      if (!EmailValidator.validate(value)) {
                        return "Invalid email";
                      }

                      return null;
                    },
                    decoration: decorationTextfield.copyWith(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                    ),
                  ),

                  SizedBox(height: 15),

                  /// PASSWORD
                  TextFormField(
                    controller: passwordController,
                    obscureText: ShwoPass,
                    onChanged: onPasswordChanged,
                    validator: (value) {
                      final p = value ?? "";
                      if (p.length < 8) return "Minimum 8 characters";
                      return null;
                    },
                    decoration: decorationTextfield.copyWith(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          ShwoPass ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            ShwoPass = !ShwoPass;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  /// PASSWORD CHECKS
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        buildCheck("At least 8 characters", isPassword8Char),
                        buildCheck("Contains number", hasNumber),
                        buildCheck("Uppercase letter", hasUppercase),
                        buildCheck("Lowercase letter", hasLowercase),
                        buildCheck("Special character", hasSpecialChar),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),

                  /// REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                register();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 15),

                  /// LOGIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => Login()),
                          );
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: appbarGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
