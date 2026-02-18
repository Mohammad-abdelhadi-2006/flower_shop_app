import 'package:firebase_auth/firebase_auth.dart';
import 'package:flower_shop_app/shared/colors.dart';
import 'package:flower_shop_app/shared/contants.dart';
import 'package:flower_shop_app/shared/snackBar.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

final _formKey = GlobalKey<FormState>();

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnackBar(context, "Please enter your email");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showSnackBar(context, "Reset link sent to your email");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(context, "No user found with this email");
      } else if (e.code == 'invalid-email') {
        showSnackBar(context, "Invalid email format");
      } else {
        showSnackBar(context, "Something went wrong");
      }
    } catch (e) {
      showSnackBar(context, "Error occurred");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarGreen,
        title: const Text("Reset Password"),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,

        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ICON
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: appbarGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_reset, size: 45, color: appbarGreen),
                ),

                const SizedBox(height: 20),

                // TITLE
                const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Enter your email to receive a reset link",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 30),

                /// EMAIL FIELD
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: decorationTextfield.copyWith(
                    hintText: "Enter your email",
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 25),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              resetPassword();
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                /// BACK BUTTON
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                      color: appbarGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
