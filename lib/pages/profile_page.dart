// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flower_shop_app/provider/user_provider.dart';
import 'package:flower_shop_app/shared/colors.dart';
import 'package:flower_shop_app/shared/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  String formatDate(DateTime? date) {
    if (date == null) return "No Data";
    return DateFormat("dd MMM yyyy ").format(date);
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = FirebaseStorage.instance.ref().child("users/$uid/$fileName");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _changeAvatar(UserProvider userP) async {
    if (userP.isLoading) return;
    if (userP.uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No logged-in user")));
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      final file = File(picked.path);

      final url = await _uploadAvatar(uid: userP.uid!, file: file);

      await context.read<UserProvider>().updateProfile(
        username: (userP.username ?? "").trim(),
        age: userP.age ?? 0, 
        address: (userP.address ?? "").trim(),
        photoUrl: url,
      );

    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update photo: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userP = context.watch<UserProvider>();

    final username =
        (userP.username != null && userP.username!.trim().isNotEmpty)
        ? userP.username!.trim()
        : "No Name";

    final email = userP.email ?? "No Email";
    final age = userP.age?.toString() ?? "No Data";

    final address = (userP.address != null && userP.address!.trim().isNotEmpty)
        ? userP.address!.trim()
        : "No Data";

    final hasPhoto =
        (userP.photoUrl != null && userP.photoUrl!.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: Color(0xffF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffF4F6F9),
        foregroundColor: Colors.black,
        title: Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: userP.isLoading
                ? null
                : () async {
                    await context.read<UserProvider>().loadUser();
                  },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: userP.isLoading
          ? Center(child: CircularProgressIndicator())
          : userP.error != null
          ? Center(child: Text("Error: ${userP.error}"))
          : SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [btnGreen, Colors.green.shade700],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: userP.isLoading
                              ? null
                              : () async {
                                  if (userP.age == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Load profile first (age is missing)",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  await _changeAvatar(userP);
                                },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: hasPhoto
                                    ? NetworkImage(userP.photoUrl!)
                                    : null,
                                child: !hasPhoto
                                    ? Icon(
                                        Icons.person,
                                        size: 34,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      username,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: userP.isLoading
                                        ? null
                                        : () async {
                                            final newName =
                                                await showEditTextDialog(
                                                  context,
                                                  title: "Edit Name",
                                                  hint: "Enter new name",
                                                  initialValue:
                                                      userP.username ?? "",
                                                );

                                            if (newName == null ||
                                                userP.age == null)
                                              return;

                                            await context
                                                .read<UserProvider>()
                                                .updateProfile(
                                                  username: newName,
                                                  age: userP.age!,
                                                  address: (userP.address ?? "")
                                                      .trim(),
                                                );
                                          },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18),

                  // AGE
                  Row(
                    children: [
                      Expanded(
                        child: infoTile(
                          icon: Icons.cake_sharp,
                          label: "Age",
                          value: age,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: Offset(0, 4),
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: userP.isLoading
                              ? null
                              : () async {
                                  final newAge = await showEditIntDialog(
                                    context,
                                    title: "Edit Age",
                                    hint: "Enter new age",
                                    initialValue: userP.age,
                                  );

                                  if (newAge == null) return;

                                  await context
                                      .read<UserProvider>()
                                      .updateProfile(
                                        username: (userP.username ?? "").trim(),
                                        age: newAge,
                                        address: (userP.address ?? "").trim(),
                                      );
                                },
                          icon: Icon(Icons.edit, color: Colors.green),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // ADDRESS
                  Row(
                    children: [
                      Expanded(
                        child: infoTile(
                          icon: Icons.location_on,
                          label: "Address",
                          value: address,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: Offset(0, 4),
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: userP.isLoading
                              ? null
                              : () async {
                                  final newAddress = await showEditTextDialog(
                                    context,
                                    title: "Edit Address",
                                    hint: "Enter new address",
                                    initialValue: userP.address ?? "",
                                    maxLines: 2,
                                  );

                                  if (newAddress == null || userP.age == null)
                                    return;

                                  await context
                                      .read<UserProvider>()
                                      .updateProfile(
                                        username: (userP.username ?? "").trim(),
                                        age: userP.age!,
                                        address: newAddress,
                                      );
                                },
                          icon: Icon(Icons.edit, color: Colors.green),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  infoTile(
                    icon: Icons.calendar_today,
                    label: "Account Created",
                    value: formatDate(userP.createdAt),
                  ),
                  SizedBox(height: 12),

                  infoTile(
                    icon: Icons.access_time,
                    label: "Last Login",
                    value: formatDate(userP.lastLogin),
                  ),
                ],
              ),
            ),
    );
  }
}
