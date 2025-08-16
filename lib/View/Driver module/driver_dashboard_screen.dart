import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
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
  final baseColor = const Color(0xFF7B60A0);

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
        backgroundColor: baseColor,
        title: Text(
          "Driver Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   onPressed: () async {
              
          //   },
          //   icon: const Icon(Icons.exit_to_app, color: Colors.white),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            buildAttendanceStatusCards(currentUid),
            dashboardCard(
              title: "Total Assigned Students",
              icon: Icons.school_outlined,
              onTap: () => _navigate(context, DriverMyStudentsScreen()),
              stream:
                  FirebaseFirestore.instance
                      .collection('students')
                      .where('assignedDriverId', isEqualTo: currentUid)
                      .snapshots(),
              valueExtractor: (snapshot) => snapshot.docs.length,
              subtitle: "Tap to view more",
            ),
            dashboardCard(
              title: "New Notifications",
              icon: Icons.notifications_outlined,
              onTap: () => _navigate(context, DriverNotificationScreen()),
              stream:
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .where('targetRole', isEqualTo: "driver")
                      .snapshots(),
              valueExtractor: (snapshot) => snapshot.docs.length,
              subtitle: "Tap to view all",
            ),
            dashboardCard(
              title: "Fee Defaulters",
              icon: Icons.error_outline,
              onTap: () => _navigate(context, FeeDefaultersScreen()),
              stream:
                  FirebaseFirestore.instance
                      .collection('students')
                      .where('assignedDriverId', isEqualTo: currentUid)
                      .where('paymentStatus', whereIn: ['Pending', 'Overdue'])
                      .snapshots(),
              valueExtractor: (snapshot) => snapshot.docs.length,
            ),
            dashboardCard(
              title: "Assigned Route for Today",
              icon: Icons.alt_route_outlined,
              onTap: () => _navigate(context, DriverRouteDetailsScreen()),
              stream:
                  FirebaseFirestore.instance
                      .collection('routes')
                      .where('assignedDriverId', isEqualTo: currentUid)
                      .snapshots(),
              customBuilder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No routes assigned", style: valueStyle);
                }
                final routes = snapshot.data!.docs;
                int totalStops = routes.fold(
                  0,
                  (sum, doc) =>
                      sum + ((doc['stops'] as List<dynamic>?)?.length ?? 0),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. of routes: ${routes.length}",
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                    Text(
                      "No. of stops: $totalStops",
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Stream<QuerySnapshot> stream,
    int Function(QuerySnapshot)? valueExtractor,
    String? subtitle,
    Widget Function(BuildContext, AsyncSnapshot<QuerySnapshot>)? customBuilder,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            gradient: LinearGradient(
              colors: [const Color(0xFF7B60A0), const Color(0xFF937BBF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B60A0).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -25.w,
                top: -25.h,
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 55.h,
                      width: 55.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Icon(icon, size: 28.w, color: Colors.white),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          StreamBuilder<QuerySnapshot>(
                            stream: stream,
                            builder: (context, snapshot) {
                              if (customBuilder != null) {
                                return customBuilder(context, snapshot);
                              }
                              if (!snapshot.hasData) {
                                return Text("0", style: valueStyle);
                              }
                              int count = valueExtractor!(snapshot.data!);
                              return Text(count.toString(), style: valueStyle);
                            },
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _attendanceCard(
              currentUid: currentUid,
              session: 'morning',
              title: "Morning",
              todayString: todayString,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _attendanceCard(
              currentUid: currentUid,
              session: 'evening',
              title: "Evening",
              todayString: todayString,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceCard({
    required String currentUid,
    required String session,
    required String title,
    required String todayString,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('driverAttendance')
              .where('driverId', isEqualTo: currentUid)
              .where('date', isEqualTo: todayString)
              .where('session', isEqualTo: session)
              .snapshots(),
      builder: (context, snapshot) {
        bool isMarked = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        return InkWell(
          onTap: () {
            if (!isMarked) {
              Navigator.pushNamed(context, "/driverPinAttendance");
            }
          },
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                colors:
                    isMarked
                        ? [Colors.green.shade500, Colors.green.shade700]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isMarked ? Colors.green : Colors.orange).withOpacity(
                    0.3,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
                      color: Colors.white.withOpacity(0.95),
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
      },
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
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
      ),
    );
  }
}
