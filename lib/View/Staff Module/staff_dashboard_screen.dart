import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_route_info_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_student_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final baseColor = const Color(0xFF7B60A0);
  final TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  final TextStyle countStyle = TextStyle(
    color: Colors.white,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );

  String? assignedDriverId;
  String? assignedRouteId;

  @override
  void initState() {
    super.initState();
    _fetchStaffAssignment();
  }

  Future<void> _fetchStaffAssignment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final staffDoc =
        await FirebaseFirestore.instance.collection('staff').doc(uid).get();
    if (staffDoc.exists) {
      final data = staffDoc.data()!;
      setState(() {
        assignedDriverId = data['assignedDriverId'];
        assignedRouteId = data['assignedRouteId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (assignedDriverId == null || assignedRouteId == null) {
      // Show loader while fetching staff assignment info
      return Scaffold(
        appBar: AppBar(
          title: const Text("Staff Dashboard"),
          backgroundColor: baseColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Streams for Students and Routes filtered by assignedDriverId and assignedRouteId
    final studentsStream =
        FirebaseFirestore.instance
            .collection('students')
            .where('assignedDriverId', isEqualTo: assignedDriverId)
            .where('assignedRouteId', isEqualTo: assignedRouteId)
            .snapshots();

    final routesStream =
        FirebaseFirestore.instance
            .collection('routes')
            .where('assignedDriverId', isEqualTo: assignedDriverId)
            .where(FieldPath.documentId, isEqualTo: assignedRouteId)
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: baseColor,
        title: const Text(
          "Staff Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isstaffLoggedIn', false);
              final authController = Provider.of<LoginController>(
                context,
                listen: false,
              );
              authController.signOut(context);
            },
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            dashboardCard(
              title: "Total Students",
              icon: Icons.school_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StaffStudentsScreen(
                          assignedDriverId!,
                          assignedRouteId!,
                        ),
                  ),
                );
              },
              stream: studentsStream,
              valueExtractor: (snapshot) => snapshot.docs.length,
              subtitle: "Tap to view your students",
            ),
            dashboardCard(
              title: "Assigned Route",
              icon: Icons.alt_route_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StaffRouteInfoScreen(
                          assignedRouteId: assignedRouteId!,
                        ),
                  ),
                );
              },
              // stream: routesStream,
              // valueExtractor: (snapshot) => snapshot.docs.length,
              subtitle: "Tap to view your route",
            ),
            dashboardCard(
              title: "View Map",
              icon: Icons.map_outlined,
              onTap: () {
                // TODO: Navigate to Staff Map screen
              },
              stream: null,
              valueExtractor: null,
              subtitle: "Tap to view on map",
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
    Stream<QuerySnapshot>? stream,
    int Function(QuerySnapshot)? valueExtractor,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 55.h,
                  width: 55.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: Icon(icon, size: 28.w, color: Colors.white),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: titleStyle),
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
                            if (!snapshot.hasData) {
                              return Text("0", style: countStyle);
                            }
                            int count =
                                valueExtractor != null
                                    ? valueExtractor(snapshot.data!)
                                    : snapshot.data!.docs.length;
                            return Text("$count", style: countStyle);
                          },
                        )
                      else
                        Text(
                          subtitle ?? '',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
