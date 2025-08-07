import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';

import 'package:vignan_transportation_management/View/Common%20Screens/profile_selection_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_home_screen.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_home_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_home_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Color palette based on 0xff7e57c2
  static const Color primaryPurple = Color(0xff7e57c2);
  static const Color lightPurple = Color(0xff9c7fd6);
  static const Color darkPurple = Color(0xff5a3f8a);

  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    log("checking login status");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check both user and admin login statuses
    bool isAdminLoggedIn = prefs.getBool('isadminLoggedIn') ?? false;

    bool isDriverLoggedIn = prefs.getBool('isdriverLoggedIn') ?? false;
    bool isStudentLoggedIn = prefs.getBool('isstudentLoggedIn') ?? false;
    bool isStaffLoggedIn = prefs.getBool('isstaffLoggedIn') ?? false;
    bool isParentLoggedIn = prefs.getBool('isparentLoggedIn') ?? false;

    //loggings
    log("isadminLoggedIn: $isAdminLoggedIn");
    log("isdriverLoggedIn: $isDriverLoggedIn");
    log("isstudentLoggedIn: $isStudentLoggedIn");
    log("isstaffLoggedIn: $isStaffLoggedIn");
    log("isparentLoggedIn: $isParentLoggedIn");

    // Wait for 4 seconds, then navigate based on login status
    Timer(Duration(seconds: 3), () {
      if (isAdminLoggedIn) {
        // Navigate to
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AdminCustomBottomNavbarScreen()),
        );
      } else if (isStudentLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StudentHomeScreen()),
        );
      } else if (isStaffLoggedIn) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => StaffHomeScreen()));
      } else if (isParentLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ParentHomeScreen()),
        );
      } else if (isDriverLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DriverHomeScreen()),
        );
      } else {
        log("profile screen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileSelectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff81ADD8),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset(scale: 3.w, 'assets/images/vtm_logo.png')),
          SizedBox(height: 20.h),
          Column(
            children: [
              Text(
                "VIGNAN TRANSPORTATION",
                textAlign: TextAlign.center,
                style: TextStyle(
                  foreground:
                      Paint()
                        ..shader = const LinearGradient(
                          colors: [primaryPurple, darkPurple],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "MANAGEMENT",
                textAlign: TextAlign.center,
                style: TextStyle(
                  foreground:
                      Paint()
                        ..shader = const LinearGradient(
                          colors: [primaryPurple, darkPurple],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
