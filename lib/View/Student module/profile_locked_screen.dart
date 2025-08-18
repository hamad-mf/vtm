import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';

class ProfileLockedScreen extends StatelessWidget {
  const ProfileLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Account Locked',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red[600],
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            onPressed: () async {
              _showSignOutDialog(context);
            },
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon with Animation Effect
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red[200]!, width: 2),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 60.sp,
                    color: Colors.red[600],
                  ),
                ),

                SizedBox(height: 32.h),

                // Main Title
                Text(
                  'Account Locked',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Main Message Card
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 40.sp,
                          color: Colors.orange[600],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Transportation Fee Payment Required',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Your transportation fee has expired and the grace period has ended. Please renew your fee to continue using the transportation services.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Instructions Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'How to Unlock Your Account',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildInstructionItem(
                        '1.',
                        'Contact the college administration office',
                      ),
                      _buildInstructionItem(
                        '2.',
                        'Make the transportation fee payment',
                      ),
                      _buildInstructionItem(
                        '3.',
                        'Your account will be unlocked automatically after payment verification',
                      ),
                      _buildInstructionItem(
                        '4.',
                        'Sign in again to access all features',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Contact Information Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.contact_phone,
                          color: Colors.green[600],
                          size: 32.sp,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Contact the administration office for assistance with fee payment and account unlock',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSignOutDialog(context),
                    icon: Icon(Icons.exit_to_app),
                    label: Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[600]),
              SizedBox(width: 12.w),
              Text(
                'Sign Out',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out? You will need to sign in again after paying your fee.',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isstudentLoggedIn', false);
                final authController = Provider.of<LoginController>(
                  context,
                  listen: false,
                );
                authController.signOut(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
