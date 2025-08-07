import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/edit_student_sheet.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xFFfbeaff),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailTile("Name", studentData['name']),
                detailTile(
                  "Registration Number",
                  studentData['registrationNumber'],
                ),
                detailTile("Email", studentData['email']),
                detailTile("Mobile Number", studentData['mobileNumber']),
                detailTile("Address", studentData['address']),
                detailTile("Assigned Route", studentData['assignedRoute']),
                detailTile("Payment Status", studentData['paymentStatus']),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder:
                              (_) => EditStudentSheet(
                                studentId: studentId,
                                studentData: studentData,
                              ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF00c9a7),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await context.read<StudentController>().deleteStudent(
                          studentId,
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget detailTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        "$title: ${value ?? '-'}",
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
