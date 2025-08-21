import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  final valueStyle = TextStyle(
    color: Colors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  final labelStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  String? _studentName;
  String? _studentId;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    log(currentUid);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7B60A0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            // Profile Info Card
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('parents')
                      .where('parentId', isEqualTo: currentUid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildLoadingCard();
                }

                final parentData =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;
                log(parentData.toString());

                // Fetch student information if available
                _fetchStudentInfo(parentData['studentId']);

                return _buildProfileCard(parentData);
              },
            ),
            SizedBox(height: 16.h),

            // Student Information Card
            if (_studentName != null)
              Column(children: [_buildStudentCard(), SizedBox(height: 16.h)]),

            // Parent-specific Action Cards
            // _buildActionCard(
            //   title: "Track Bus",
            //   subtitle: "View real-time bus location",
            //   icon: Icons.directions_bus_outlined,
            //   onTap: () {
            //     // Navigate to bus tracking screen
            //     // Navigator.push(context, _slidePageRoute(BusTrackingScreen()));
            //   },
            // ),
            SizedBox(height: 16.h),

            // _buildActionCard(
            //   title: "Notifications",
            //   subtitle: "View bus alerts and updates",
            //   icon: Icons.notifications_outlined,
            //   onTap: () {
            //     // Navigate to notifications screen
            //     // Navigator.push(context, _slidePageRoute(NotificationsScreen()));
            //   },
            // ),
            // SizedBox(height: 16.h),

            // _buildActionCard(
            //   title: "Contact Driver",
            //   subtitle: "Get in touch with the bus driver",
            //   icon: Icons.phone_outlined,
            //   onTap: () {
            //     // Navigate to contact screen
            //     // Navigator.push(context, _slidePageRoute(ContactDriverScreen()));
            //   },
            // ),
            SizedBox(height: 24.h),

            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchStudentInfo(String? studentId) async {
    if (studentId == null || studentId.isEmpty) return;

    try {
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(studentId)
              .get();

      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _studentName = studentData['name'];
          _studentId = studentId;
        });
      }
    } catch (e) {
      log('Error fetching student info: $e');
    }
  }

  Widget _buildProfileCard(Map<String, dynamic> parentData) {
    return Container(
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
          _buildFadedCircle(left: -30.w, top: 100.h, size: 70),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 50.w,
                  ),
                ),
                SizedBox(height: 20.h),

                // Parent Name
                Text(
                  parentData['parentName'] ?? 'Parent Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                // Email
                Text(
                  parentData['email'] ?? 'email@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                // Parent Details
                _buildInfoRow(
                  "Relationship",
                  parentData['relationship'] ?? 'Parent',
                ),
                SizedBox(height: 12.h),

                // Phone Number
                if (parentData['parentMobileNo'] != null)
                  Column(
                    children: [
                      _buildInfoRow("Phone", parentData['parentMobileNo']),
                      SizedBox(height: 12.h),
                    ],
                  ),

                // Emergency Contact (if available)
                if (parentData['parentMobileNo'] != null)
                  Column(
                    children: [
                      _buildInfoRow(
                        "Emergency Contact",
                        parentData['parentMobileNo'],
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),

                // Address (if available)
                if (parentData['parentAddress'] != null)
                  Column(
                    children: [
                      _buildInfoRow("Address", parentData['parentAddress']),
                      SizedBox(height: 12.h),
                    ],
                  ),

                // Registration Date (if available)
                if (parentData['StudentRegNo'] != null)
                  _buildInfoRow(
                    "Student register no",
                    (parentData['StudentRegNo']),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D8AA8), Color(0xFF7EB0D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D8AA8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildFadedCircle(
            right: -15.w,
            top: -5.h,
            size: 60,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildFadedCircle(
            right: 30.w,
            bottom: -10.h,
            size: 45,
            color: Colors.white.withOpacity(0.1),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
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
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Student",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _studentName ?? 'Loading...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_studentId != null)
                        Text(
                          "ID: $_studentId",
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
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 400.h,
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
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Flexible(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B60A0), Color(0xFF937BBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B60A0).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildFadedCircle(right: -15.w, top: -5.h, size: 60),
            _buildFadedCircle(right: 30.w, bottom: -10.h, size: 45),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Container(
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
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 16.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_outlined, color: Colors.red, size: 24.w),
            SizedBox(width: 12.w),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFadedCircle({
    double? right,
    double? left,
    double? top,
    double? bottom,
    required double size,
    Color? color,
  }) {
    return Positioned(
      right: right,
      left: left,
      top: top,
      bottom: bottom,
      child: Container(
        height: size.h,
        width: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? Colors.white.withOpacity(0.08),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "Logout",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('isparentLoggedIn', false);
                  final authController = Provider.of<LoginController>(
                    context,
                    listen: false,
                  );
                  authController.signOut(context);
                } catch (e) {
                  log('Logout error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error occurred during logout'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}
