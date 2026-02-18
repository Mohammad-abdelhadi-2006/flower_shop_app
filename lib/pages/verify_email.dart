// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flower_shop_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flower_shop_app/pages/home.dart';
import 'package:flower_shop_app/shared/colors.dart';
import 'package:flower_shop_app/shared/snackBar.dart';

class VerifyEmailPage extends StatefulWidget {
  VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(Duration(seconds: 3), (timer) async {
        await FirebaseAuth.instance.currentUser!.reload();

        setState(() {
          isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        });

        if (isEmailVerified) {
          timer.cancel();
        }
      });
    }
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      setState(() {
        canResendEmail = false;
      });

      await Future.delayed(Duration(seconds: 10));

      setState(() {
        canResendEmail = true;
      });

      showSnackBar(context, "Verification email sent");
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return Home();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Verify Email"),
          backgroundColor: appbarGreen,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ICON
                Icon(Icons.mark_email_unread, size: 120, color: btnGreen),

                SizedBox(height: 30),

                /// TITLE
                Text(
                  "Check your email",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 15),

                /// DESCRIPTION
                Text(
                  "We sent a verification link to:\n${FirebaseAuth.instance.currentUser!.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),

                SizedBox(height: 30),

                /// RESEND BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnGreen,
                      padding: EdgeInsets.all(15),
                    ),
                    child: Text("Resend Email", style: TextStyle(fontSize: 18)),
                  ),
                ),

                SizedBox(height: 10),

                /// CANCEL BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnPink,
                      padding: EdgeInsets.all(15),
                    ),
                    child: Text("Cancel", style: TextStyle(fontSize: 18)),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
  }
}
