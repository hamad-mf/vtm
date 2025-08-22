import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'package:vignan_transportation_management/View/Admin%20module/fcm_service.dart'; // For call if needed

// Adjust the import path

class DriverQrAttendanceScreen extends StatefulWidget {
  final String driverId;
  const DriverQrAttendanceScreen({required this.driverId, Key? key})
    : super(key: key);

  @override
  State<DriverQrAttendanceScreen> createState() =>
      _DriverQrAttendanceScreenState();
}

class _DriverQrAttendanceScreenState extends State<DriverQrAttendanceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;

  String sessionMode = "Auto"; // Auto / Morning / Evening

  Future<bool> _isStudentAssigned(String studentId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();
    return doc.exists && doc.data()?['assignedDriverId'] == widget.driverId;
  }

  Future<bool> _isDuplicateAttendance(String studentId, String session) async {
    String today = DateTime.now().toIso8601String().substring(0, 10);
    final query =
        await FirebaseFirestore.instance
            .collection('studentAttendance')
            .where('studentId', isEqualTo: studentId)
            .where('date', isEqualTo: today)
            .where('session', isEqualTo: session)
            .limit(1)
            .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _sendAttendanceNotification(
    String studentId,
    String session,
  ) async {
    try {
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(studentId)
              .get();
      if (!studentDoc.exists) return;
      final studentData = studentDoc.data()!;
      final studentName = studentData['name'] ?? "Your child";

      // Find parent(s) userId(s) associated with this student
      final parentQuery =
          await FirebaseFirestore.instance
              .collection('parents')
              .where(
                'StudentRegNo',
                isEqualTo: studentData['registrationNumber'],
              )
              .get();

      if (parentQuery.docs.isEmpty) return;

      // Craft notification message depending on session
      String message = "";
      if (session.toLowerCase() == "morning") {
        message = "$studentName has arrived at college safely.";
      } else if (session.toLowerCase() == "evening") {
        message = "$studentName is in the bus and will be at home soon.";
      }

      // Send notifications to all parents found
      for (var parentDoc in parentQuery.docs) {
        String parentId = parentDoc.id;

        // Fetch user token from roles collection or wherever tokens are stored
        final tokenDocs =
            await FirebaseFirestore.instance
                .collection('roles')
                .where(
                  'userId',
                  isEqualTo: parentId,
                ) // Assuming your roles collection has userId field
                .where('role', isEqualTo: 'parent')
                .get();

        for (var tokenDoc in tokenDocs.docs) {
          String? token = tokenDoc.data()['fcmToken'];
          if (token != null && token.isNotEmpty) {
            await FCMService.sendNotificationToToken(
              token: token,
              title: "Attendance Marked",
              body: message,
              projectId: "vtm-8559d", // Your Firebase project id here
            );
          }
        }

        // Save notification in Firestore
        await FirebaseFirestore.instance.collection('notifications').add({
          'targetRole': 'parent',
          'targetUserId': parentId,
          'title': "Attendance Marked",
          'body': message,
          'timestamp': FieldValue.serverTimestamp(),
          'date': DateTime.now().toIso8601String().substring(0, 10),
        });
      }
    } catch (e) {
      log("Error sending attendance notification: $e");
    }
  }

  Future<void> _confirmAndMark(String studentId) async {
    String session;
    if (sessionMode == "Auto") {
      session = DateTime.now().hour < 12 ? 'Morning' : 'Evening';
    } else {
      session = sessionMode;
    }

    if (await _isDuplicateAttendance(studentId, session)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepPurple,
          content: Text("Already marked for $session today!"),
        ),
      );
      return;
    }

    final studentDoc =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();
    final name = studentDoc.data()?['name'] ?? "Unknown";

    bool confirmed =
        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text("Mark Attendance?"),
                content: Text("Student: $name\nSession: $session"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmed) return;

    await FirebaseFirestore.instance.collection('studentAttendance').add({
      'studentId': studentId,
      'driverId': widget.driverId,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'session': session,
      'status': 'Present',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send notification after successful marking
    await _sendAttendanceNotification(studentId, session);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF7B61A1),
        content: Text("Attendance marked successfully!"),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isScanning) return;

      isScanning = false;

      final studentId = scanData.code ?? "";
      if (studentId.isEmpty) {
        isScanning = true;
        return;
      }

      if (!await _isStudentAssigned(studentId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Not assigned to this driver!"),
          ),
        );
        isScanning = true;
        return;
      }

      await _confirmAndMark(studentId);

      Future.delayed(Duration(seconds: 2), () => isScanning = true);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan for Attendance'),
        backgroundColor: Color(0xFF7B61A1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Color(0xFF7B61A1),
                borderRadius: 12,
                borderLength: 35,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Session Mode: $sessionMode', style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                ['Auto', 'Morning', 'Evening'].map((mode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(mode),
                      selected: sessionMode == mode,
                      onSelected: (selected) {
                        setState(() {
                          sessionMode = mode;
                        });
                      },
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
