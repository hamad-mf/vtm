import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Common%20Screens/profile_selection_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_home_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_home_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/profile_locked_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_custom_bottom_navbar_screen.dart';

class LoginController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error Signing out"),
        ),
      );
    }
  }

  onLogin({
    required String enteredRegNo,
    required String email,
    required String password,
    required BuildContext context,
    required String passedrole,
    required String? token,
  }) async {
    isloading = true;
    notifyListeners();

    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credentials.user?.uid != null) {
        String uid = credentials.user!.uid;

        // 1. Fetch role document
        DocumentSnapshot roldoc =
            await _firestore.collection('roles').doc(uid).get();

        if (roldoc.exists) {
          String role = roldoc['role'];
          log("role of the user : $role");

          // 2. Validate role
          if (passedrole != role) {
            isloading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid credentials")));
            return;
          }

          // 3. If parent, perform StudentRegNo verification
          if (role == "parent") {
            DocumentSnapshot parentDoc =
                await _firestore.collection('parents').doc(uid).get();

            if (!parentDoc.exists) {
              isloading = false;
              notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Parent data not found")));
              return;
            }

            String? storedStudentRegNo = parentDoc['StudentRegNo'];

            if (enteredRegNo != storedStudentRegNo) {
              isloading = false;
              notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Student Registration No Verification Failed"),
                ),
              );
              await _auth.signOut();
              return;
            }
          }

          // 4. If FCM token provided, update roles collection
          if (token != null) {
            await _firestore.collection('roles').doc(uid).update({
              'fcmToken': token,
              'tokenUpdatedAt': FieldValue.serverTimestamp(),
            });
            log("Updated FCM token for $uid: $token");
          }

          // 5. Store login status
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is${role}LoggedIn', true);

          isloading = false;
          notifyListeners();

          // 6. Navigate to home screens
          switch (role) {
            case 'admin':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminCustomBottomNavbarScreen(),
                ),
                (route) => false,
              );
              break;
            case 'driver':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => DriverCustomBottomNavbar(initialIndex: 0),
                ),
                (route) => false,
              );
              break;
            case 'student':
              // UPDATED: Check fee status with corrected expiry logic
              final statusInfo = await StudentController.getStudentStatusInfo(uid);
              final String paymentStatus = statusInfo['paymentStatus'];
              final bool isGraceActive = statusInfo['isGraceActive'];
              final int? daysUntilExpiry = statusInfo['daysUntilExpiry'];
              final bool shouldShowBanner = statusInfo['shouldShowBanner'] ?? false;

              log("Student payment status: $paymentStatus");
              log("Days until expiry: $daysUntilExpiry");
              log("Grace active: $isGraceActive");
              log("Should show banner: $shouldShowBanner");

              if (paymentStatus == "Paid" || paymentStatus == "Grace") {
                // Navigate to student dashboard
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentCustomBottomNavbarScreen(
                      initialIndex: 0,
                      isGraceActive: isGraceActive,
                    ),
                  ),
                  (route) => false,
                );

                // Show appropriate notification after navigation
                Future.delayed(Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    if (shouldShowBanner && daysUntilExpiry != null) {
                      // Show 7-day renewal warning (when status is still "Paid")
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Your transport service renewal is due in $daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'}. Please pay to continue enjoying the service.",
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 6),
                        ),
                      );
                    } else if (isGraceActive && daysUntilExpiry != null) {
                      // Show grace period warning (when status is "Grace")
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Grace Period Active: Fee expired ${(-daysUntilExpiry)} day${(-daysUntilExpiry) == 1 ? '' : 's'} ago. Please renew to avoid service interruption.",
                          ),
                          backgroundColor: Colors.red[600],
                          duration: Duration(seconds: 6),
                        ),
                      );
                    }
                  }
                });
                
              } else if (paymentStatus == "Pending" || paymentStatus == "Overdue") {
                // Navigate to profile locked screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileLockedScreen()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Unknown fee status: $paymentStatus")));
              }
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
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Unknown role: $role")));
          }
        } else {
          isloading = false;
          notifyListeners();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User role not found")));
        }
      }
    } on FirebaseAuthException catch (e) {
      log(e.code.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.message}")));
      isloading = false;
      notifyListeners();
    } catch (e) {
      log("Unexpected error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("An unexpected error occurred")));
      isloading = false;
      notifyListeners();
    }
  }
}