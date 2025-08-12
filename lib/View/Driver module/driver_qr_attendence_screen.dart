import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class DriverQrAttendanceScreen extends StatefulWidget {
  final String driverId;
  const DriverQrAttendanceScreen({required this.driverId});

  @override
  State<DriverQrAttendanceScreen> createState() =>
      _DriverQrAttendanceScreenState();
}

class _DriverQrAttendanceScreenState extends State<DriverQrAttendanceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;

  String sessionMode = "Auto"; // Auto / Morning / Evening

  // ✅ Check if student belongs to this driver
  Future<bool> _isStudentAssigned(String studentId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();
    return doc.exists && doc.data()?['assignedDriverId'] == widget.driverId;
  }

  // ✅ Prevent duplicates
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

  // ✅ Confirm and Mark Attendance
  Future<void> _confirmAndMark(String studentId) async {
    String session;
    if (sessionMode == "Auto") {
      session = DateTime.now().hour < 12 ? 'Morning' : 'Evening';
    } else {
      session = sessionMode;
    }

    // Prevent duplicates
    if (await _isDuplicateAttendance(studentId, session)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Already marked for $session today!")),
      );
      return;
    }

    // Show confirm dialog with student name if available
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
                title: Text("Mark Attendance?"),
                content: Text("Student: $name\nSession: $session"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Confirm"),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmed) return;

    // Mark attendance
    await FirebaseFirestore.instance.collection('studentAttendance').add({
      'studentId': studentId,
      'driverId': widget.driverId,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'session': session,
      'status': 'Present',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Attendance marked successfully!")));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Not assigned to this driver!")));
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
        title: Text("Scan Student QR"),
        actions: [
          PopupMenuButton<String>(
            initialValue: sessionMode,
            onSelected: (val) => setState(() => sessionMode = val),
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: "Auto", child: Text("Auto Detect")),
                  PopupMenuItem(value: "Morning", child: Text("Morning")),
                  PopupMenuItem(value: "Evening", child: Text("Evening")),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                // ✅ Square frame
                borderColor: Colors.green,
                borderRadius: 8,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Mode: $sessionMode — Hold QR inside the frame",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
