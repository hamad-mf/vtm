import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vtm/View/Common%20Screens/login_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen>
    with TickerProviderStateMixin {
  bool isuserSelected = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color palette based on 0xff7e57c2
  static const Color primaryPurple = Color(0xff7e57c2); //ok
  static const Color lightPurple = Color(0xff9c7fd6); // ok
  static const Color darkPurple = Color(0xff5a3f8a); 
  static const Color veryDarkPurple = Color(0xff4a2f73);
  static const Color accentPurple = Color(0xffb39ddb);
  static const Color backgroundPurple = Color(0xfff3f0ff);
  static const Color textPurple = Color(0xff271F33);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundPurple, Colors.white, backgroundPurple],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),

                      // Enhanced Header with decorative elements
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryPurple, lightPurple],
                                ),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              "VIGNAN TRANSPORTATION",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                foreground:
                                    Paint()
                                      ..shader = const LinearGradient(
                                        colors: [primaryPurple, darkPurple],
                                      ).createShader(
                                        const Rect.fromLTWH(
                                          0.0,
                                          0.0,
                                          200.0,
                                          70.0,
                                        ),
                                      ),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              "MANAGEMENT",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                foreground:
                                    Paint()
                                      ..shader = const LinearGradient(
                                        colors: [primaryPurple, darkPurple],
                                      ).createShader(
                                        const Rect.fromLTWH(
                                          0.0,
                                          0.0,
                                          200.0,
                                          70.0,
                                        ),
                                      ),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Enhanced Logo Container
                      Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [lightPurple, primaryPurple, darkPurple],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.all(3.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/red_question.png',
                              scale: 8.w,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25.h),

                      Text(
                        "Select Your Role",
                        style: TextStyle(
                          color: textPurple,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),

                      Text(
                        "Choose the appropriate login option",
                        style: TextStyle(
                          color: textPurple.withOpacity(0.7),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: 35.h),

                      // Enhanced Role Buttons
                      _buildRoleButton(
                        "ADMIN",
                        Icons.admin_panel_settings,
                        () => _navigateToLogin(
                          FontAwesomeIcons.screwdriverWrench,
                          "admin",
                        ),
                        [primaryPurple, darkPurple],
                      ),
                      SizedBox(height: 20.h),

                      _buildRoleButton(
                        "DRIVER",
                        Icons.local_shipping,
                        () => _navigateToLogin(
                          FontAwesomeIcons.busSimple,
                          "driver",
                        ),
                        [lightPurple, primaryPurple],
                      ),
                      SizedBox(height: 20.h),

                      _buildRoleButton(
                        "USER",
                        Icons.person,
                        () => _toggleUserSelection(),
                        isuserSelected
                            ? [veryDarkPurple, darkPurple]
                            : [primaryPurple, lightPurple],
                        isSelected: isuserSelected,
                      ),
                      SizedBox(height: 20.h),

                      _buildRoleButton(
                        "PARENT",
                        Icons.family_restroom,
                        () => _navigateToLogin(
                          FontAwesomeIcons.personBreastfeeding,
                          "parent",
                        ),
                        [accentPurple, primaryPurple],
                      ),

                      SizedBox(height: 25.h),

                      // Enhanced User Sub-options with animation
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child:
                            isuserSelected
                                ? Container(
                                  margin: EdgeInsets.only(top: 5.h),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildSubRoleButton(
                                            "STUDENT",
                                            Icons.school,
                                            () => _navigateToLogin(
                                              FontAwesomeIcons.graduationCap,
                                              "student",
                                            ),
                                            [primaryPurple, lightPurple],
                                          ),
                                          _buildSubRoleButton(
                                            "STAFF",
                                            Icons.work,
                                            () => _navigateToLogin(
                                              FontAwesomeIcons.personChalkboard,
                                              "staff",
                                            ),
                                            [darkPurple, primaryPurple],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    String text,
    IconData icon,
    VoidCallback onTap,
    List<Color> gradientColors, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 55.h,
        width: 320.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: isSelected ? 20 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 18.sp,
                letterSpacing: 1.0,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 10.w),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20.sp),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubRoleButton(
    String text,
    IconData icon,
    VoidCallback onTap,
    List<Color> gradientColors,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 50.h,
        width: 140.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(height: 2.h),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 13.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(IconData icon, String role) {
    setState(() {
      isuserSelected = false;
    });
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                LoginScreen(icon: icon, role: role),
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

  void _toggleUserSelection() {
    log("user selected");
    setState(() {
      isuserSelected = !isuserSelected;
    });
  }
}
