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
          backgroundColor: const Color(0xFF7B61A1),
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
                    child: Text("Confirm"),
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
    final themeColor = const Color(0xFF7B61A1);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B61A1), Color(0xFF937BBF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Scan Student QR",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          // QR Scanner View
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: themeColor,
                borderRadius: 12,
                borderLength: 35,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),

          // Session Selection
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                const Text(
                  "Select Session Mode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      ["Auto", "Morning", "Evening"].map((mode) {
                        final isSelected = sessionMode == mode;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(
                              mode,
                              style: TextStyle(
                                color: isSelected ? Colors.white : themeColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => sessionMode = mode);
                            },
                            selectedColor: themeColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: themeColor),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mode: $sessionMode — Hold QR inside the frame to scan",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
