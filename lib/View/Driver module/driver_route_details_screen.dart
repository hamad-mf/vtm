import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverRouteDetailsScreen extends StatelessWidget {
  const DriverRouteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("My Route")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('routes')
            .where('assignedDriverId', isEqualTo: driverId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No route assigned"));

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final stops = (data['stops'] as List).map((s) => s.toString()).toList();
          final timings = (data['timings'] as List).map((t) => t.toString()).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Route: ${data['routeName']}", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              Text("Stops:", style: const TextStyle(fontWeight: FontWeight.bold)),
              ...stops.map((s) => Text("- $s")),
              const SizedBox(height: 12),
              Text("Timings:", style: const TextStyle(fontWeight: FontWeight.bold)),
              ...timings.map((t) => Text("- $t")),
            ],
          );
        },
      ),
    );
  }
}
