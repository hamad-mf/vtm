import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_driver_details_screen.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_student_details_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final Color baseColor = const Color(0xFF7B60A0);
  final TextStyle valueStyle = TextStyle(
    color: Colors.white,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );

  String? studentRegNo;
  String? driverId;

  @override
  void initState() {
    super.initState();
    _fetchParentData();
  }

  Future<void> _fetchParentData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    var parentDoc =
        await FirebaseFirestore.instance.collection('parents').doc(uid).get();
    if (parentDoc.exists) {
      final data = parentDoc.data();
      if (data != null && mounted) {
        setState(() {
          studentRegNo = data['StudentRegNo'] as String? ?? '';
        });
        if (studentRegNo != null && studentRegNo!.isNotEmpty) {
          _fetchDriverId();
        }
      }
    }
  }

  Future<void> _fetchDriverId() async {
    if (studentRegNo == null || studentRegNo!.isEmpty) return;
    var studentQuery =
        await FirebaseFirestore.instance
            .collection('students')
            .where('registrationNumber', isEqualTo: studentRegNo)
            .limit(1)
            .get();
    log("got std data");
    if (studentQuery.docs.isNotEmpty) {
      var studentData = studentQuery.docs.first.data();
      if (mounted) {
        setState(() {
          driverId = studentData['assignedDriverId'] as String?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: baseColor,
        title: Text(
          "Parent Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          studentRegNo == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  children: [
                    dashboardCard(
                      title: "Live Map",
                      icon: Icons.map_outlined,
                      subtitle: "Track your child's bus live",
                      onTap: () {
                        Navigator.pushNamed(context, '/parentLiveMap');
                      },
                      stream: null,
                    ),
                    dashboardCard(
                      title: "Student Details",
                      icon: Icons.school_outlined,
                      subtitle: "View your child's details",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ParentStudentDetailsScreen(
                                  studentRegNo: studentRegNo!,
                                ),
                          ),
                        );
                      },
                      stream:
                          FirebaseFirestore.instance
                              .collection('students')
                              .where(
                                'registrationNumber',
                                isEqualTo: studentRegNo,
                              )
                              .snapshots(),
                    ),
                    dashboardCard(
                      title: "Driver Details",
                      icon: Icons.person_outline,
                      subtitle:
                          driverId == null
                              ? "Loading Driver Details..."
                              : "View your child's driver details",
                      onTap:
                          driverId == null
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ParentDriverDetailsScreen(
                                          driverId: driverId!,
                                        ),
                                  ),
                                );
                              },
                      stream:
                          driverId == null
                              ? null
                              : FirebaseFirestore.instance
                                  .collection('drivers')
                                  .where(
                                    'assignedDriverId',
                                    isEqualTo: driverId,
                                  )
                                  .snapshots(),
                    ),
                    dashboardCard(
                      title: "Notifications",
                      icon: Icons.notifications_outlined,
                      subtitle: "View latest notifications",
                      onTap: () {
                        Navigator.pushNamed(context, '/parentNotifications');
                      },
                      stream:
                          FirebaseFirestore.instance
                              .collection('notifications')
                              .where('targetRole', isEqualTo: 'parent')
                              .snapshots(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback? onTap,
    Stream<QuerySnapshot>? stream,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            gradient: LinearGradient(
              colors: [baseColor, baseColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.4),
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
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (stream != null)
                            StreamBuilder<QuerySnapshot>(
                              stream: stream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                    color: Colors.white,
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Text('0', style: valueStyle);
                                }
                                return Text(
                                  snapshot.data!.docs.length.toString(),
                                  style: valueStyle,
                                );
                              },
                            )
                          else
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14.sp,
                              ),
                            ),
                          SizedBox(height: 6.h),
                          if (onTap != null)
                            Text(
                              "Tap to view details",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12.sp,
                              ),
                            ),
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
}
