import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverLeaveScreen extends StatelessWidget {
  const DriverLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("My Leaves")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('driverLeave')
            .where('driverId', isEqualTo: driverId)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No leaves"));
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, idx) {
              final data = snapshot.data!.docs[idx].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text("Date: ${data['date']}"),
                  subtitle: Text("Remark: ${data['remark']}"),
                  trailing: data['replacementDriverId'] != null
                      ? Text("Replacement: ${data['replacementDriverId']}")
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
