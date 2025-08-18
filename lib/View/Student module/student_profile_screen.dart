import 'package:flutter/material.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_travel_calender_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentTravelCalendarScreen(),
                  ),
                );
              },
              child: Text("stdent calender"),
            ),
          ),
        ],
      ),
    );
  }
}
