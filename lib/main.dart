import 'package:flutter/material.dart';
import 'package:vtm/View/Common%20Screens/profile_selection_screen.dart';

void main(List<String> args) {
  runApp(MyApp());
  
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileSelectionScreen(),
    );
  }
}
