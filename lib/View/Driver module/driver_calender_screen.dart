import 'package:flutter/material.dart';

class DriverCalenderScreen extends StatefulWidget {
  const DriverCalenderScreen({super.key});

  @override
  State<DriverCalenderScreen> createState() => _DriverCalenderScreenState();
}

class _DriverCalenderScreenState extends State<DriverCalenderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("calender"),),
    );
  }
}