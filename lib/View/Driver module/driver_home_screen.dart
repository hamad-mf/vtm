import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isdriverLoggedIn', false);
              final authController = Provider.of<LoginController>(
                context,
                listen: false,
              );
              authController.signOut(context);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(child: Text("driver home")),
    );
  }
}
