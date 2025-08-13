import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_calender_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_dashboard_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_map_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_pin_attendence_screen.dart';
import 'package:vignan_transportation_management/View/Driver%20module/driver_students_screen.dart';

class DriverCustomBottomNavbar extends StatefulWidget {
  final int initialIndex;
  const DriverCustomBottomNavbar({required this.initialIndex, super.key});

  @override
  State<DriverCustomBottomNavbar> createState() =>
      _DriverCustomBottomNavbarState();
}

class _DriverCustomBottomNavbarState extends State<DriverCustomBottomNavbar>
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

  final List<Widget> _screens = [
    DriverDashboardScreen(),
    DriverStudentsScreen(),
    DriverMapScreen(),
    DriverPinAttendanceScreen(),
    DriverCalendarScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'selectedIcon': Icons.dashboard,
      'unselectedIcon': Icons.dashboard_outlined,
      'label': 'Dashboard',
      'color': primaryPurple,
    },
    {
      'selectedIcon': Icons.school,
      'unselectedIcon': Icons.school_outlined,
      'label': 'Students',
      'color': lightPurple,
    },
    {
      'selectedIcon': Icons.directions_bus,
      'unselectedIcon': Icons.directions_bus_outlined,
      'label': 'Map',
      'color': accentPurple,
    },
    {
      'selectedIcon': Icons.bar_chart,
      'unselectedIcon': Icons.bar_chart_outlined,
      'label': 'attendence',
      'color': darkPurple,
    },
    {
      'selectedIcon': Icons.settings,
      'unselectedIcon': Icons.settings_outlined,
      'label': 'calender',
      'color': darkPurple,
    },
  ];

  void _onNavItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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