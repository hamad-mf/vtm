import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/add_parent_screen.dart';

import 'package:vignan_transportation_management/View/Admin%20module/add_student_screen.dart';
import 'package:vignan_transportation_management/View/Admin%20module/manage_students_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontSize: 19.sp)),
      ),
      body: Center(
        child: Column(
          children: [
            // Add Students Card
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddParentScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  height: 140.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Color(0xff7b61a1),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff7b61a1).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background decoration circles
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

                      // Main content
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
                                  "Add Parent",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Register new parents",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Tap to add parents",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Icon
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
                              FontAwesomeIcons.userPlus,
                              size: 24.w,
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

            // Manage Students Card
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
              child: InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('isadminLoggedIn', false);
                  final authController = Provider.of<LoginController>(
                    context,
                    listen: false,
                  );
                  authController.signOut(context);
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  height: 140.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Color(0xff007ebf),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff007ebf).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background decoration circles
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

                      // Main content
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
                                  "Log out now",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Log out from admin portal",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Tap to log out",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Icon
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
                              FontAwesomeIcons.userGear,
                              size: 24.w,
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
