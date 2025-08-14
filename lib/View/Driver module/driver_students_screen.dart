import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_my_students_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_qr_attendence_screen.dart';

class DriverStudentsScreen extends StatefulWidget {
  const DriverStudentsScreen({super.key});

  @override
  State<DriverStudentsScreen> createState() => _DriverStudentsScreenState();
}

class _DriverStudentsScreenState extends State<DriverStudentsScreen> {
  final valueStyle = TextStyle(
    color: Colors.white,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    log(currentUid);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Students", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7B60A0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            _buildDashboardCard(
              title: "Total Assigned Students",
              stream:
                  FirebaseFirestore.instance
                      .collection('students')
                      .where('assignedDriverId', isEqualTo: currentUid)
                      .snapshots(),
              icon: Icons.school_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  _slidePageRoute(const DriverMyStudentsScreen()),
                );
              },
            ),
            SizedBox(height: 16.h),
            _buildDashboardCard(
              title: "Take Student Attendance",
              stream: null,
              icon: Icons.qr_code_scanner,
              onTap: () {
                Navigator.push(
                  context,
                  _slidePageRoute(
                    DriverQrAttendanceScreen(driverId: currentUid),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    Stream<QuerySnapshot>? stream,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B60A0), Color(0xFF937BBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B60A0).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildFadedCircle(right: -20.w, top: -10.h, size: 80),
            _buildFadedCircle(right: 40.w, bottom: -15.h, size: 60),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      stream != null
                          ? StreamBuilder<QuerySnapshot>(
                            stream: stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text("0", style: valueStyle);
                              }
                              int count = snapshot.data!.docs.length;
                              return Text(count.toString(), style: valueStyle);
                            },
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  Text(
                    "Tap to view more",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20.w,
              top: 20.h,
              child: Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(
                  icon,
                  size: 28.w,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFadedCircle({
    required double right,
    double? top,
    double? bottom,
    required double size,
  }) {
    return Positioned(
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        height: size.h,
        width: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
      ),
    );
  }

  PageRouteBuilder _slidePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }
}
