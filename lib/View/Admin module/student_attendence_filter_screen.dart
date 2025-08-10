import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/route_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/student_attendence_log_screen.dart';

class StudentAttendanceFilterScreen extends StatefulWidget {
  const StudentAttendanceFilterScreen({super.key});

  @override
  State<StudentAttendanceFilterScreen> createState() => _StudentAttendanceFilterScreenState();
}

class _StudentAttendanceFilterScreenState extends State<StudentAttendanceFilterScreen> {
  String? selectedRouteId;
  String? selectedSession;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final routeController = Provider.of<RouteController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Filter Student Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder(
              stream: routeController.getAllRoutes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final routes = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Select Route"),
                  value: selectedRouteId,
                  items: routes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['routeName'] ?? 'Unnamed Route'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedRouteId = val),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Session"),
              value: selectedSession,
              items: ['morning', 'evening']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedSession = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "Date not selected"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                  child: const Text("Select Date"),
                )
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (selectedRouteId != null && selectedSession != null && selectedDate != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentAttendanceLogScreen(
                            routeId: selectedRouteId!,
                            session: selectedSession!,
                            date: selectedDate!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text("View Attendance Logs"),
            )
          ],
        ),
      ),
    );
  }
}
