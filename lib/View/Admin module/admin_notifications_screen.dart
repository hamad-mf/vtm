import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'fcm_service.dart'; // your FCM sending service

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  String selectedRole = 'driver';
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  bool sending = false;

  Future<void> sendToRole() async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and body')),
      );
      return;
    }

    setState(() => sending = true);

    try {
      // Query the `roles` collection for the selected role
      final docs =
          await FirebaseFirestore.instance
              .collection('roles')
              .where('role', isEqualTo: selectedRole)
              .get();

      if (docs.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No $selectedRole found')));
      } else {
        for (var doc in docs.docs) {
          final token = doc['fcmToken'];
          if (token != null && token.isNotEmpty) {
            await FCMService.sendNotificationToToken(
              projectId: "vtm-8559d", // change to yours
              token: token,
              title: titleController.text.trim(),
              body: bodyController.text.trim(),
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sent to all $selectedRole users'),
          ),
        );
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending: $e')));
    }

    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple; // Match your theme’s accent color

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeColor,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Select Role",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'driver', child: Text("Drivers")),
                    DropdownMenuItem(value: 'student', child: Text("Students")),
                    DropdownMenuItem(value: 'staff', child: Text("Staff")),
                    DropdownMenuItem(value: 'parent', child: Text("Parents")),
                  ],
                  onChanged: (val) {
                    setState(() => selectedRole = val ?? 'driver');
                  },
                ),
                const SizedBox(height: 16),

                // Title field
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Notification Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Body field
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Notification Body",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Send button
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon:
                        sending
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.send),
                    label: Text(sending ? "Sending..." : "Send Notification"),
                    onPressed: sending ? null : sendToRole,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
