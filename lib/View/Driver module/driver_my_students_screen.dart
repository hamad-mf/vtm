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

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Students")),
        body: const Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Assigned Students")),
      body: StreamBuilder<QuerySnapshot>(
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
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: Text(student['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reg No: ${student['registrationNumber'] ?? '-'}"),
                      Text("Route: ${student['assignedRoute'] ?? '-'}"),
                      Text("Fee: ${student['paymentStatus'] ?? '-'}"),
                      Text("Mobile: ${student['mobileNumber'] ?? '-'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
