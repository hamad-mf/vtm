import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';

import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_notifications_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_my_students_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_notification_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_route_details_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/fee_defaulters_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
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
      appBar: AppBar(
        title: Text("Dashboard"),
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildAttendanceStatusCards(currentUid),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 16.w,
                  ),
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
                              DriverNotificationScreen(),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 16.w,
                  ),
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
                                    "New notifications",
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
                                            .collection('notifications')
                                            .where(
                                              'targetRole',
                                              isEqualTo: "driver",
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
                                "Tap to view All",
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
                              Icons.notifications_outlined,
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
                              FeeDefaultersScreen(),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 16.w,
                  ),
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
                                    "Fee Defaulters",
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
                                            .where(
                                              'paymentStatus',
                                              whereIn: ['Pending', 'Overdue'],
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
                              // Text(
                              //   "Tap to view more",
                              //   style: TextStyle(
                              //     color: Colors.white.withOpacity(0.8),
                              //     fontSize: 12.sp,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
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
                              Icons.error_outline,
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
                              DriverRouteDetailsScreen(),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 16.w,
                  ),
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
                                    "Assigned Route for today",
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
                                            .collection('routes')
                                            .where(
                                              'assignedDriverId',
                                              isEqualTo: currentUid,
                                            )
                                            .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Text("0", style: valueStyle);
                                      }

                                      final routes = snapshot.data!.docs;

                                      if (routes.isEmpty) {
                                        return Text(
                                          "No routes assigned",
                                          style: valueStyle,
                                        );
                                      }

                                      // Calculate the total number of stops
                                      int totalStopCount = 0;
                                      final routeNames =
                                          routes.map((doc) {
                                            final data =
                                                doc.data()
                                                    as Map<String, dynamic>;
                                            final routeName =
                                                data['routeName'] as String? ??
                                                'N/A';
                                            final stops =
                                                data['stops'] as List<dynamic>?;

                                            final stopCount =
                                                stops?.length ?? 0;
                                            totalStopCount +=
                                                stopCount; // Add the current route's stop count to the total
                                            final timings =
                                                data['timings']
                                                    as List<dynamic>?;
                                            return Text(
                                              "Name of route: $routeName",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.white,
                                              ),
                                            );
                                          }).toList();

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "no of routes: ${routes.length}",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                          // Display the calculated total stop count here
                                          Text(
                                            "no of stops: $totalStopCount",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                          // Display all the route names
                                          Column(children: routeNames),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // Text(
                              //   "Tap to view more",
                              //   style: TextStyle(
                              //     color: Colors.white.withOpacity(0.8),
                              //     fontSize: 12.sp,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
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
                              Icons.error_outline,
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
      ),
    );
  }

  Widget buildAttendanceStatusCards(String currentUid) {
    String todayString =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
      child: Row(
        children: [
          // Morning card
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('driverAttendance')
                      .where('driverId', isEqualTo: currentUid)
                      .where('date', isEqualTo: todayString)
                      .where('session', isEqualTo: 'morning')
                      .snapshots(),
              builder: (context, snapshot) {
                bool isMarked =
                    snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                return buildSessionCard(
                  title: "Morning",
                  isMarked: isMarked,
                  onTap: () {
                    if (!isMarked) {
                      Navigator.pushNamed(context, "/driverPinAttendance");
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(width: 10.w),
          // Evening card
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('driverAttendance')
                      .where('driverId', isEqualTo: currentUid)
                      .where('date', isEqualTo: todayString)
                      .where('session', isEqualTo: 'evening')
                      .snapshots(),
              builder: (context, snapshot) {
                bool isMarked =
                    snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                return buildSessionCard(
                  title: "Evening",
                  isMarked: isMarked,
                  onTap: () {
                    if (!isMarked) {
                      Navigator.pushNamed(context, "/driverPinAttendance");
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSessionCard({
    required String title,
    required bool isMarked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isMarked ? Colors.green.shade600 : Colors.orange.shade600,
          boxShadow: [
            BoxShadow(
              color: (isMarked ? Colors.green : Colors.orange).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$title Session",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isMarked ? "✅ Marked" : "⚠️ Not Marked",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
