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

  final List<String> sessions = ['morning', 'evening'];

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

      String todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

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

      var lastAttendanceSnap =
          await FirebaseFirestore.instance
              .collection('driverAttendance')
              .where('driverId', isEqualTo: driverId)
              .orderBy('date', descending: true)
              .limit(1)
              .get();

      if (lastAttendanceSnap.docs.isNotEmpty) {
        DateTime lastDate = DateTime.parse(
          lastAttendanceSnap.docs.first['date'],
        );

        DateTime currentDate = DateTime(today.year, today.month, today.day);
        DateTime nextDay = lastDate.add(Duration(days: 1));

        while (nextDay.isBefore(currentDate)) {
          String missingDateStr =
              "${nextDay.year}-${nextDay.month.toString().padLeft(2, '0')}-${nextDay.day.toString().padLeft(2, '0')}";

          for (String session in ['morning', 'evening']) {
            await FirebaseFirestore.instance
                .collection('driverAttendance')
                .add({
                  'driverId': driverId,
                  'date': missingDateStr,
                  'session': session,
                  'status': 'absent',
                  'createdAt': FieldValue.serverTimestamp(),
                });
          }
          nextDay = nextDay.add(Duration(days: 1));
        }
      }

      var attendanceCheck =
          await FirebaseFirestore.instance
              .collection('driverAttendance')
              .where('driverId', isEqualTo: driverId)
              .where('date', isEqualTo: todayStr)
              .where('session', isEqualTo: _selectedSession)
              .get();

      if (attendanceCheck.docs.isNotEmpty) {
        throw Exception(
          "Attendance already marked for $_selectedSession session today",
        );
      }

      await FirebaseFirestore.instance.collection('driverAttendance').add({
        'driverId': driverId,
        'date': todayStr,
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
      appBar: AppBar(
        title: Text(
          "Driver PIN Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B60A0), Color(0xFF937BBF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F2FA), Color(0xFFEAE4F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B60A0),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: "Enter 6-digit PIN",
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF7B60A0)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF7B60A0), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select Session",
                  prefixIcon: Icon(Icons.access_time, color: Color(0xFF7B60A0)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF7B60A0), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed:
                        (_selectedSession == null)
                            ? null
                            : verifyPinAndMarkAttendance,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Color(0xFF7B60A0),
                    ),
                    child: Text(
                      "Mark Attendance",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              if (_message != null) ...[
                SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        _message!.startsWith("Error")
                            ? Colors.red
                            : Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
