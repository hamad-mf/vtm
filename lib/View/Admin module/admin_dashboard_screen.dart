import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_custom_bottom_navbar.dart';
import 'package:vignan_transportation_management/View/Admin%20module/admin_notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final valueStyle = TextStyle(
    color: Colors.white,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(fontSize: 19.sp)),
      ),
      body: Center(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            AdminCustomBottomNavbarScreen(initialIndex: 1),
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
                  (route) => false,
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
                                  "Total Students",
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
              child: Container(
                height: 140.h,
                width: 350.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Color(0xff7A60A1),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff7A60A1).withOpacity(0.3),
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
                                "Drivers",
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
                                        .collection('drivers')
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
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.bus,
                            size: 28.w,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
              child: Container(
                height: 140.h,
                width: 350.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Color(0xff7e57c2),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff7e57c2).withOpacity(0.3),
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
                                "Bus routes",
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
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.road,
                            size: 28.w,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                            AdminNotificationScreen(),
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
                    color: Color(0xffb39ddb),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffb39ddb).withOpacity(0.3),
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
                                  "Alerts",
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
                                          .collection('alerts')
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
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.bell,
                              size: 28.w,
                              color: Colors.white.withOpacity(0.9),
                            ),
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
