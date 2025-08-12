import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeeDefaultersScreen extends StatelessWidget {
  const FeeDefaultersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("Fee Defaulters")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('students')
                .where('assignedDriverId', isEqualTo: driverId)
                .where('paymentStatus', whereIn: ['Pending', 'Overdue'])
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No defaulters"));
          return ListView(
            children:
                snapshot.data!.docs.map((doc) {
                  var s = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(s['name']),
                    subtitle: Text(
                      "${s['registrationNumber']} – ${s['paymentStatus']}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.error, color: Colors.red),
                      onPressed: () {
                        // Optional: integrate phone dialer
                      },
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
