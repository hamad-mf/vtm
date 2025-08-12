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
      appBar: AppBar(title: Text("Students")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            DriverMyStudentsScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
                child: Container(
                  height: 140.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Color(0xff5a3f8a),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff5a3f8a).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20.w,
                        top: -10.h,
                        child: Container(
                          height: 80.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40.w,
                        bottom: -15.h,
                        child: Container(
                          height: 60.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
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
                                  "Total Assigned Students",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                StreamBuilder<QuerySnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('students')
                                          .where(
                                            'assignedDriverId',
                                            isEqualTo: currentUid,
                                          )
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Text("0", style: valueStyle);
                                    }
                                    int count = snapshot.data!.docs.length;
                                    return Text(
                                      count.toString(),
                                      style: valueStyle,
                                    );
                                  },
                                ),
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
                            Icons.school_outlined,
                            size: 28.w,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            DriverQrAttendanceScreen(driverId: currentUid),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
                child: Container(
                  height: 140.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Color(0xff5a3f8a),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff5a3f8a).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20.w,
                        top: -10.h,
                        child: Container(
                          height: 80.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40.w,
                        bottom: -15.h,
                        child: Container(
                          height: 60.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
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
                                  "Take student attendecne",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
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
                            Icons.school_outlined,
                            size: 28.w,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
