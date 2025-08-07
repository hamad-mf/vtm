import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Common%20Screens/profile_selection_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_home_screen.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_home_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_home_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_home_screen.dart';


class LoginController with ChangeNotifier {
  bool isloading = false;

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ProfileSelectionScreen()),
        (route) => false,
      );
    } catch (e) {
      // Handle errors if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error Siginin out"),
        ),
      );
    }
  }

  onLogin({
    required String email,
    required String password,
    required BuildContext context,
    required String passedrole,
  }) async {
    isloading = true;
    notifyListeners();

    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (credentials.user?.uid != null) {
        String uid = credentials.user!.uid;
        // fetch user role
        DocumentSnapshot roldoc =
            await FirebaseFirestore.instance.collection('roles').doc(uid).get();
        if (roldoc.exists) {
          String role = roldoc['role'];
          log("role of the user : $role");

          // Validate role match
          if (passedrole != role) {
            isloading = false;
            notifyListeners();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
            return;
          }

          // Store login status
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is${role}LoggedIn', true);
         final key = 'is${role}LoggedIn';
final value = prefs.getBool(key);
log("$key: $value");
          // Navigate accordingly
          switch (role) {
            case 'admin':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AdminCustomBottomNavbarScreen()),
                (route) => false,
              );
              break;

            case 'driver':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => DriverHomeScreen()),
                (route) => false,
              );
              break;

            case 'student':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => StudentHomeScreen()),
                (route) => false,
              );
              break;

            case 'staff':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => StaffHomeScreen()),
                (route) => false,
              );
              break;

            case 'parent':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => ParentHomeScreen()),
                (route) => false,
              );
              break;

            default:
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Unknown role: $role")));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      log(e.code.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${e.message}")));
      isloading = false;
      notifyListeners();
    }
  }
}
