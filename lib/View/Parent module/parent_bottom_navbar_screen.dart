import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_dashboard_screen.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_map_screen.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_profile_screen.dart';
import 'package:vignan_transportation_management/View/Parent%20module/parent_student_attendence_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_dashboard_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_map_screen.dart';
import 'package:vignan_transportation_management/View/Staff%20Module/staff_profile_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_dashboard_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_map_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_profile_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_qe_screen.dart';

class ParentBottomNavbarScreen extends StatefulWidget {
  final int initialIndex;
  const ParentBottomNavbarScreen({required this.initialIndex, super.key});

  @override
  State<ParentBottomNavbarScreen> createState() =>
      _ParentBottomNavbarScreenState();
}

class _ParentBottomNavbarScreenState extends State<ParentBottomNavbarScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  int _currentIndex = 0;
  static const Color primaryPurple = Color(0xff7e57c2);
  static const Color lightPurple = Color(0xff9c7fd6);
  static const Color darkPurple = Color(0xff5a3f8a);
  static const Color veryDarkPurple = Color(0xff4a2f73);
  static const Color accentPurple = Color(0xffb39ddb);
  static const Color backgroundPurple = Color(0xfff3f0ff);
  static const Color softPurple = Color(0xffe1d5f7);

  final List<Map<String, dynamic>> _navItems = [
    {
      'selectedIcon': Icons.dashboard,
      'unselectedIcon': Icons.dashboard_outlined,
      'label': 'Dashboard',
      'color': primaryPurple,
    },
    {
      'selectedIcon': Icons.map,
      'unselectedIcon': Icons.map_outlined,
      'label': 'Map',
      'color': lightPurple,
    },
    {
      'selectedIcon': Icons.bar_chart,
      'unselectedIcon': Icons.bar_chart_outlined,
      'label': 'attendence',
      'color': accentPurple,
    },
    {
      'selectedIcon': Icons.person,
      'unselectedIcon': Icons.person_outline,
      'label': 'Profile',
      'color': accentPurple,
    },
  ];

  void _onNavItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      ParentDashboardScreen(),
      ParentMapScreen(),
      ParentStudentAttendenceScreen(),
      ParentProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 65.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? _navItems[index]['selectedIcon']
                    : _navItems[index]['unselectedIcon'],
                color: isSelected ? primaryPurple : Colors.grey,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                _navItems[index]['label'],
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? primaryPurple : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
