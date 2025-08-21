import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffStudentsScreen extends StatelessWidget {
  final String assignedDriverId;
  final String assignedRouteId;

  const StaffStudentsScreen(this.assignedDriverId, this.assignedRouteId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
        .collection('students')
        .where('assignedDriverId', isEqualTo: assignedDriverId)
        .where('assignedRouteId', isEqualTo: assignedRouteId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Students"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students assigned."));
          }
          final students = snapshot.data!.docs;
          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final student = students[index];
              final data = student.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text('Reg#: ${data['registrationNumber'] ?? 'N/A'}'),
                trailing: Text(data['paymentStatus'] ?? ''),
                onTap: () {
                  // Navigate to student detail page if available
                },
              );
            },
          );
        },
      ),
    );
  }
}