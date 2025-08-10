import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverPinAttendanceScreen extends StatefulWidget {
  @override
  _DriverPinAttendanceScreenState createState() =>
      _DriverPinAttendanceScreenState();
}

class _DriverPinAttendanceScreenState extends State<DriverPinAttendanceScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  // Example: you may pass these from your app context or auth session
  final String session = 'evening'; // or 'evening'
  final DateTime today = DateTime.now();

  Future<void> verifyPinAndMarkAttendance() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      String inputPin = _pinController.text.trim();

      if (inputPin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(inputPin)) {
        throw Exception("Enter a valid 6-digit PIN");
      }

      // Query drivers collection to find driver with matching PIN
      var querySnapshot =
          await FirebaseFirestore.instance
              .collection('drivers')
              .where('pincode', isEqualTo: inputPin)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Invalid PIN: No driver found");
      }

      // Assume single driver match
      var driverDoc = querySnapshot.docs.first;
      String driverId = driverDoc.id;

      // Format date as YYYY-MM-DD
      String dateString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Check if attendance already marked today for this session
      var attendanceQuery =
          await FirebaseFirestore.instance
              .collection('driverAttendance')
              .where('driverId', isEqualTo: driverId)
              .where('date', isEqualTo: dateString)
              .where('session', isEqualTo: session)
              .get();

      if (attendanceQuery.docs.isNotEmpty) {
        setState(() {
          _message = "Attendance already marked for this session";
          _isLoading = false;
        });
        return;
      }

      // Mark attendance
      await FirebaseFirestore.instance.collection('driverAttendance').add({
        'driverId': driverId,
        'date': dateString,
        'session': session,
        'status': 'present',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _message = "Attendance marked successfully";
      });
    } catch (e) {
      setState(() {
        _message = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver PIN Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: "Enter 6-digit PIN",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: verifyPinAndMarkAttendance,
                  child: Text("Mark Attendance"),
                ),
            if (_message != null) ...[
              SizedBox(height: 20),
              Text(
                _message!,
                style: TextStyle(
                  color:
                      _message!.startsWith("Error") ? Colors.red : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
