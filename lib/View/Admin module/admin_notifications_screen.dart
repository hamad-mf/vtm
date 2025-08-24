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
  String selectedOption = 'everyone';
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  bool sending = false;

  // For custom selection
  final Set<String> selectedCustomUserIds = {};

  Future<void> sendNotification() async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and body')),
      );
      return;
    }

    setState(() => sending = true);

    try {
      QuerySnapshot<Map<String, dynamic>> docs;

      // Get users by option
      if (selectedOption == 'everyone') {
        docs = await FirebaseFirestore.instance.collection('roles').get();
      } else if (selectedOption == 'users') {
        docs =
            await FirebaseFirestore.instance
                .collection('roles')
                .where('role', whereIn: ['student', 'staff'])
                .get();
      } else if (selectedOption == 'parents') {
        docs =
            await FirebaseFirestore.instance
                .collection('roles')
                .where('role', isEqualTo: 'parent')
                .get();
      } else if (selectedOption == 'drivers') {
        docs =
            await FirebaseFirestore.instance
                .collection('roles')
                .where('role', isEqualTo: 'driver')
                .get();
      } else if (selectedOption == 'custom') {
        if (selectedCustomUserIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No custom users selected')),
          );
          setState(() => sending = false);
          return;
        }
        docs =
            await FirebaseFirestore.instance
                .collection('roles')
                .where(
                  FieldPath.documentId,
                  whereIn: selectedCustomUserIds.toList(),
                )
                .get();
      } else {
        docs = await FirebaseFirestore.instance.collection('roles').get();
      }

      if (docs.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No users found for $selectedOption')),
        );
      } else {
        for (var doc in docs.docs) {
          final token = doc.data()['fcmToken'] as String?;
          if (token != null && token.isNotEmpty) {
            await FCMService.sendNotificationToToken(
              projectId:
                  "vtm-8559d", // change to your actual Firebase projectId
              token: token,
              title: titleController.text.trim(),
              body: bodyController.text.trim(),
            );
          }
        }

        // Save notification history
        await FirebaseFirestore.instance.collection('notifications').add({
          'targetOption': selectedOption,
          'title': titleController.text.trim(),
          'body': bodyController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'customTargets':
              selectedOption == 'custom'
                  ? selectedCustomUserIds.toList()
                  : null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification sent to $selectedOption')),
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

  Future<void> _openCustomSelectionDialog() async {
    final rolesSnapshot =
        await FirebaseFirestore.instance.collection('roles').get();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Users"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView(
                  children:
                      rolesSnapshot.docs.map((doc) {
                        final userId = doc.id;
                        // final userId = doc.id;
                        final role = doc['role'];
                        final name = doc['name'];
                        return CheckboxListTile(
                          title: Text("$role – $name"),
                          value: selectedCustomUserIds.contains(userId),
                          onChanged: (checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                selectedCustomUserIds.add(userId);
                              } else {
                                selectedCustomUserIds.remove(userId);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notification Send Options",
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
                  "Send To",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: selectedOption,
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
                    DropdownMenuItem(
                      value: 'everyone',
                      child: Text("Everyone"),
                    ),
                    DropdownMenuItem(
                      value: 'users',
                      child: Text("Users (Students + Staff)"),
                    ),
                    DropdownMenuItem(
                      value: 'parents',
                      child: Text("Only Parents"),
                    ),
                    DropdownMenuItem(
                      value: 'drivers',
                      child: Text("Only Drivers"),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text("Custom Selection"),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => selectedOption = val ?? 'everyone');
                    if (val == 'custom') {
                      _openCustomSelectionDialog();
                    }
                  },
                ),
                const SizedBox(height: 16),

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
                    onPressed: sending ? null : sendNotification,
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
