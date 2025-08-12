import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverNotificationScreen extends StatelessWidget {
  const DriverNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('targetRole', isEqualTo: 'driver')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No notifications yet"));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(data['body'] ?? ''),
                  trailing: Text(data['date'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
