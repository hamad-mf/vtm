import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_qe_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isstudentLoggedIn', false);
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
      body: Center(
        child: Column(
          children: [
            Text("student home"),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentQrScreen()),
                );
                ;
              },
              child: Text("get my qr"),
            ),
          ],
        ),
      ),
    );
  }
}
