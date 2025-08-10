import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/attendence_controller.dart';

class StudentAttendanceLogScreen extends StatefulWidget {
  final String routeId;
  final String session;
  final DateTime date;
  const StudentAttendanceLogScreen({
    Key? key,
    required this.routeId,
    required this.session,
    required this.date,
  }) : super(key: key);

  @override
  State<StudentAttendanceLogScreen> createState() =>
      _StudentAttendanceLogScreenState();
}

class _StudentAttendanceLogScreenState
    extends State<StudentAttendanceLogScreen> {
  String? selectedRouteId;
  String? selectedSession;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Attendance Logs")),
      body: Column(
        children: [
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text("Session"),
                  value: selectedSession,
                  items:
                      ['morning', 'evening']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => selectedSession = v),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Text(
                    selectedDate == null
                        ? "Pick Date"
                        : selectedDate.toString().split(" ")[0],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: context.read<AttendanceController>().getStudentAttendance(
                routeId: selectedRouteId,
                date: selectedDate,
                session: selectedSession,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty)
                  return const Center(child: Text("No records"));

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return ListTile(
                      title: Text("Student ID: ${data['studentId']}"),
                      subtitle: Text(
                        "${data['date']} - ${data['session']} - ${data['status']}",
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
