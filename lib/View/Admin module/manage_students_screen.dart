import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/student_detail_screen.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color? Cardcolor;
    Color? TextColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Available Students')),
      body: StreamBuilder(
        stream: context.read<StudentController>().getAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No students found'));

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (_, i) {
              final data = students[i].data();
              final id = students[i].id;
              final paymentStatus = data['paymentStatus'];

              if (paymentStatus == 'Paid') {
                Cardcolor = Color(0xff00c9a7);
              } else if (paymentStatus == "Pending") {
                Cardcolor = Color(0xffff8600);
              } else {
                Cardcolor = Color(0xffBE2525);
              }
              if (paymentStatus == 'Paid') {
                TextColor = Color(0xff000000);
              } else if (paymentStatus == "Pending") {
                TextColor = Color(0xffffffff);
              } else {
                TextColor = Color(0xffffffff);
              }

              return Card(
                color: Cardcolor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    data['name'] ?? '',
                    style: TextStyle(color: TextColor),
                  ),
                  subtitle: Text(
                    "Payment Status: ${data['paymentStatus']}",
                    style: TextStyle(color: TextColor),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => StudentDetailScreen(
                              studentId: id,
                              studentData: data,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
