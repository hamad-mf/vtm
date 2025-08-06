import 'package:flutter/material.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

        child: Text("Admin drivers screen"),
      ),
    );
  }
}