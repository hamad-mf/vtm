import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverPinAttendanceScreen extends StatefulWidget {
  @override
  _DriverPinAttendanceScreenState createState() =>
      _DriverPinAttendanceScreenState();
}

class _DriverPinAttendanceScreenState extends State<DriverPinAttendanceScreen> {
  final _pinController = TextEditingController();
  String? _selectedSession;
  bool _isLoading = false;
  String? _message;

  final List<String> sessions = ['morning', 'evening']; // You can extend this

  DateTime today = DateTime.now();

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

      if (_selectedSession == null) {
        throw Exception("Please select a session");
      }

      // Get today's date string
      String dateString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // 1. Find driver with entered PIN
      var driverSnapshot =
          await FirebaseFirestore.instance
              .collection('drivers')
              .where('pincode', isEqualTo: inputPin)
              .limit(1)
              .get();

      if (driverSnapshot.docs.isEmpty) {
        throw Exception("Invalid PIN: No driver found");
      }

      String driverId = driverSnapshot.docs.first.id;

      // 2. Check if already marked for today + session
      var attendanceCheck =
          await FirebaseFirestore.instance
              .collection('driverAttendance')
              .where('driverId', isEqualTo: driverId)
              .where('date', isEqualTo: dateString)
              .where('session', isEqualTo: _selectedSession)
              .get();

      if (attendanceCheck.docs.isNotEmpty) {
        throw Exception(
          "Attendance already marked for $_selectedSession session today",
        );
      }

      // 3. **Only mark for today's date**
      DateTime now = DateTime.now();
      if (!(now.year == today.year &&
          now.month == today.month &&
          now.day == today.day)) {
        throw Exception("You can only mark attendance for today");
      }

      // 4. Add attendance entry
      await FirebaseFirestore.instance.collection('driverAttendance').add({
        'driverId': driverId,
        'date': dateString,
        'session': _selectedSession,
        'status': 'present',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _message = "Attendance marked successfully for $_selectedSession";
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PIN field
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

            // Session dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Session",
                border: OutlineInputBorder(),
              ),
              value: _selectedSession,
              items:
                  sessions
                      .map(
                        (session) => DropdownMenuItem<String>(
                          value: session,
                          child: Text(session.toUpperCase()),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSession = value;
                });
              },
            ),
            SizedBox(height: 20),

            // submit button
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed:
                      (_selectedSession == null)
                          ? null
                          : verifyPinAndMarkAttendance,
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
