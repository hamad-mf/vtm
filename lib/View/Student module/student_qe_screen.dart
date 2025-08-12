import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentQrScreen extends StatelessWidget {
  const StudentQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Transport QR")),
        body: const Center(child: Text("Please log in to view your QR code.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Transport QR")),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('students')
                .doc(currentUser.uid)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student record not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (data['paymentStatus'] != 'Paid') {
            return const Center(
              child: Text(
                "QR code unavailable - please pay the transport fee to access this feature.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: currentUser.uid,
                  size: 220.0,
                  // color: Colors.deepPurple, // Set color here if needed
                ),
                const SizedBox(height: 16),
                const Text(
                  "Show this code to the bus driver for attendance scanning.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your Student ID: ${currentUser.uid}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
