// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flower_shop_app/pages/forget_password.dart';
import 'package:flower_shop_app/pages/home.dart';
import 'package:flower_shop_app/pages/register.dart';
import 'package:flower_shop_app/pages/verify_email.dart';
import 'package:flower_shop_app/provider/google_sign_in_provider.dart';
import 'package:flower_shop_app/provider/user_provider.dart';
import 'package:flower_shop_app/shared/colors.dart';
import 'package:flower_shop_app/shared/contants.dart';
import 'package:flower_shop_app/shared/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

bool ShwoPass = true;

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, "Email and password are required.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: appbarGreen)),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      switch (e.code) {
        case 'user-not-found':
          showSnackBar(context, "No user found for that email.");
          break;
        case 'wrong-password':
          showSnackBar(context, "Incorrect password.");
          break;
        case 'invalid-email':
          showSnackBar(context, "Invalid email format.");
          break;
        default:
          showSnackBar(context, e.message ?? "Authentication failed.");
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      showSnackBar(context, "Unexpected error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          color: Color(0x11000000),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: appbarGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 28,
                            color: btnGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Welcome 💐😁",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Sign in to continue",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          color: Color(0x11000000),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        const Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: decorationTextfield.copyWith(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: "name@example.com",
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Password
                        const Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: ShwoPass,
                          decoration: decorationTextfield.copyWith(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: "••••••••",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  ShwoPass = !ShwoPass;
                                });
                              },
                              icon: Icon(
                                ShwoPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Forget password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPassword(),
                                ),
                              );
                            },
                            child: Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: appbarGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Sign in
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await signIn();
                              if (FirebaseAuth.instance.currentUser != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerifyEmailPage(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: btnGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Register row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Register(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: appbarGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // OR divider
                        Row(
                          children: const [
                            Expanded(child: Divider(thickness: 0.7)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(thickness: 0.7)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Google button
                        SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final cred = await context
                                  .read<GoogleSignInProvider>()
                                  .googleLogin();

                              if (cred == null) return;

                              await context.read<UserProvider>().loadUser();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Home()),
                              );
                            },

                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: const Color.fromARGB(255, 200, 67, 79),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                              Icons.g_mobiledata,
                              size: 30,
                              color: Color.fromARGB(255, 200, 67, 79),
                            ),
                            label: const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
