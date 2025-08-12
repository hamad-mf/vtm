import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodayAttendanceScreen extends StatelessWidget {
  const TodayAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Attendance")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('studentAttendance')
            .where('driverId', isEqualTo: driverId)
            .where('date', isEqualTo: today)
            .orderBy('session')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No attendance yet"));
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['studentId']),
                subtitle: Text("${data['session']} — ${data['status']}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
