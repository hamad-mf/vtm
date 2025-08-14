import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverMyStudentsScreen extends StatefulWidget {
  const DriverMyStudentsScreen({super.key});

  @override
  State<DriverMyStudentsScreen> createState() => _DriverMyStudentsScreenState();
}

class _DriverMyStudentsScreenState extends State<DriverMyStudentsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  // Gradient helper
  LinearGradient _mainGradient() => const LinearGradient(
    colors: [Color(0xFF7B60A0), Color(0xFF937BBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: _buildAppBar(),
        body: const Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackgroundAccents(),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('students')
                    .where('assignedDriverId', isEqualTo: currentUser!.uid)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No students assigned yet"));
              }

              final students = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student =
                      students[index].data() as Map<String, dynamic>;
                  final paymentStatus = student['paymentStatus'] ?? '-';

                  // Status-based gradient
                  Gradient statusGradient;
                  if (paymentStatus == 'Paid') {
                    statusGradient = const LinearGradient(
                      colors: [Color(0xFF00C9A7), Color(0xFF00E676)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else if (paymentStatus == 'Pending') {
                    statusGradient = const LinearGradient(
                      colors: [Color(0xFFFF8600), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else {
                    statusGradient = const LinearGradient(
                      colors: [Color(0xFFBE2525), Color(0xFFE57373)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: statusGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        student['name'] ?? 'No Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subtitleText(
                              "Reg No: ${student['registrationNumber'] ?? '-'}",
                            ),
                            _subtitleText(
                              "Route: ${student['assignedRoute'] ?? '-'}",
                            ),
                            _subtitleText(
                              "Fee: ${student['paymentStatus'] ?? '-'}",
                            ),
                            _subtitleText(
                              "Mobile: ${student['mobileNumber'] ?? '-'}",
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        log(paymentStatus);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: _mainGradient()),
      ),
      title: const Text(
        "My Assigned Students",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBackgroundAccents() {
    return Stack(
      children: [
        Positioned(top: -50, left: -50, child: _circleAccent(150)),
        Positioned(bottom: -60, right: -60, child: _circleAccent(180)),
      ],
    );
  }

  Widget _circleAccent(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF7B60A0).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _subtitleText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
    );
  }
}
