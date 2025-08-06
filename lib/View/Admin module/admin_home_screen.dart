import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtm/Controllers/Common%20Controllers/login_controller.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: ()async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isadminLoggedIn', false);
                    final authController = Provider.of<LoginController>(
                      context,
                      listen: false,
                    );
                    authController.signOut(context);
          }, icon:Icon(Icons.exit_to_app))
        ],
      ),
      body: Center(
        child: Text("admin home"),
      ),
    );
  }
}