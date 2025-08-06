import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vtm/View/TEST/driver_screen.dart';
import 'package:vtm/View/TEST/parent_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transport Test App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Driver Page'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DriverScreen()),
              ),
            ),
            ElevatedButton(
              child: Text('Parent Page'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ParentScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
