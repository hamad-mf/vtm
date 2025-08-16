import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Common%20Screens/profile_selection_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_home_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_home_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/profile_locked_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_custom_bottom_navbar_screen.dart';

// Import your screen files
// import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';
// ... other imports

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
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    log("checking login status");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check all user role login statuses
    bool isAdminLoggedIn = prefs.getBool('isadminLoggedIn') ?? false;
    bool isDriverLoggedIn = prefs.getBool('isdriverLoggedIn') ?? false;
    bool isStudentLoggedIn = prefs.getBool('isstudentLoggedIn') ?? false;
    bool isStaffLoggedIn = prefs.getBool('isstaffLoggedIn') ?? false;
    bool isParentLoggedIn = prefs.getBool('isparentLoggedIn') ?? false;

    // Logging
    log("isadminLoggedIn: $isAdminLoggedIn");
    log("isdriverLoggedIn: $isDriverLoggedIn");
    log("isstudentLoggedIn: $isStudentLoggedIn");
    log("isstaffLoggedIn: $isStaffLoggedIn");
    log("isparentLoggedIn: $isParentLoggedIn");

    // Wait for 3 seconds, then navigate based on login status
    Timer(Duration(seconds: 3), () async {
      if (isAdminLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AdminCustomBottomNavbarScreen()),
        );
      } else if (isStudentLoggedIn) {
        await _handleStudentAutoLogin();
      } else if (isStaffLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StaffHomeScreen()),
        );
      } else if (isParentLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ParentHomeScreen()),
        );
      } else if (isDriverLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DriverCustomBottomNavbar(initialIndex: 0),
          ),
        );
      } else {
        log("profile screen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileSelectionScreen()),
        );
      }
    });
  }

  /// Handles automatic login for students with fee expiry checking
  Future<void> _handleStudentAutoLogin() async {
    log("Student already logged in, verifying fee status...");

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // If somehow no user exists but flag is true, fallback
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfileSelectionScreen()),
      );
      return;
    }

    try {
      // Get student status with fee expiry checking
      final statusInfo = await StudentController.getStudentStatusInfo(uid);
      final String paymentStatus = statusInfo['paymentStatus'];
      final bool isGraceActive = statusInfo['isGraceActive'];
      final int? daysUntilExpiry = statusInfo['daysUntilExpiry'];

      log("Auto-login: Student payment status: $paymentStatus");
      log("Auto-login: Days until expiry: $daysUntilExpiry");
      log("Auto-login: Grace active: $isGraceActive");

      if (paymentStatus == "Paid" || paymentStatus == "Grace") {
        // Navigate to student dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => StudentCustomBottomNavbarScreen(
              initialIndex: 0,
              isGraceActive: isGraceActive,
            ),
          ),
        );

        // Show grace period warning after navigation if applicable
        if (isGraceActive && daysUntilExpiry != null) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Grace Period: Fee expires in $daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'}",
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 5),
                ),
              );
            }
          });
        }
      } else if (paymentStatus == "Pending" || paymentStatus == "Overdue") {
        // Navigate to profile locked screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileLockedScreen()),
        );
      } else {
        // Unknown status - fallback to profile selection
        log("Unknown fee status: $paymentStatus");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileSelectionScreen()),
        );
      }
    } catch (e) {
      log("Error checking student status: $e");
      // Fallback to profile selection on error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfileSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  foreground: Paint()
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
                  foreground: Paint()
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
          // Optional: Add loading indicator
          SizedBox(height: 40.h),
          CircularProgressIndicator(
            color: primaryPurple,
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }
}