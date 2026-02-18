// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flower_shop_app/model/item.dart';
import 'package:flower_shop_app/pages/checkout.dart';
import 'package:flower_shop_app/pages/details_screen.dart';
import 'package:flower_shop_app/pages/login.dart';
import 'package:flower_shop_app/pages/profile_page.dart';
import 'package:flower_shop_app/provider/cart.dart';
import 'package:flower_shop_app/provider/user_provider.dart';
import 'package:flower_shop_app/shared/appbar.dart';
import 'package:flower_shop_app/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<UserProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: Color(0xffF4F6F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: appbarGreen,
        title: Text(
          "Flower Shop",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductsAndPrice(),
          ),
        ],
      ),

      drawer: buildDrawer(context),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final product = items[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(product: product),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// IMAGE
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.asset(
                          product.imgPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    /// INFO
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          /// NAME
                          Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 5),

                          /// PRICE + BUTTON
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$12.99",
                                style: TextStyle(
                                  color: appbarGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  color: appbarGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    cart.add(product);
                                  },
                                  icon: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    final userIn = context.watch<UserProvider>();
    return Drawer(
      child: Column(
        children: [
          /// HEADER
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: appbarGreen),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: (userIn.photoUrl != null && userIn.photoUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: userIn.photoUrl!,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      )
                    : Icon(Icons.person, size: 30, color: Colors.white),
              ),
            ),

            accountName: Text(userIn.username ?? "Loading..."),
            accountEmail: Text(userIn.email ?? ""),
          ),

          /// HOME
          ListTile(
            leading: Icon(Icons.manage_accounts_sharp),
            title: Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),

          /// CART
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("My Cart"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckOut()),
              );
            },
          ),

          /// LOGOUT
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Developed by Mohammad Ahmad Hassn Abdehadi © 2026",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
