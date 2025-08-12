import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverCalendarScreen extends StatefulWidget {
  const DriverCalendarScreen({super.key});

  @override
  State<DriverCalendarScreen> createState() => _DriverCalendarScreenState();
}

class _DriverCalendarScreenState extends State<DriverCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final driverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Calendar")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2031, 1, 1),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
          ),
          if (_selectedDay != null)
            Expanded(child: _buildDayDetails(_selectedDay!)),
        ],
      ),
    );
  }

  Widget _buildDayDetails(DateTime date) {
    String dateStr = date.toIso8601String().substring(0, 10);

    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance
            .collection('driverAttendance')
            .where('driverId', isEqualTo: driverId)
            .where('date', isEqualTo: dateStr)
            .get(),
        FirebaseFirestore.instance
            .collection('studentAttendance')
            .where('driverId', isEqualTo: driverId)
            .where('date', isEqualTo: dateStr)
            .get(),
        FirebaseFirestore.instance
            .collection('driverLeave')
            .where('driverId', isEqualTo: driverId)
            .where('date', isEqualTo: dateStr)
            .get(),
        FirebaseFirestore.instance
            .collection('notifications')
            .where('targetRole', isEqualTo: 'driver')
            .where('date', isEqualTo: dateStr)
            .get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final driverAtt = snapshot.data![0];
        final studentAtt = snapshot.data![1];
        final leaveDocs = snapshot.data![2];
        final notifDocs = snapshot.data![3];

        return ListView(
          children: [
            ListTile(
              title: const Text("Driver Attendance"),
              subtitle: Text(driverAtt.docs.isEmpty
                  ? "No record"
                  : driverAtt.docs.map((d) => "${d['session']} ✅").join(", ")),
            ),
            ListTile(
              title: const Text("Students Travelled"),
              subtitle: Text("${studentAtt.docs.length}"),
            ),
            if (leaveDocs.docs.isNotEmpty)
              ListTile(
                title: const Text("Leave"),
                subtitle: Text(leaveDocs.docs.first['remark']),
              ),
            if (notifDocs.docs.isNotEmpty)
              ListTile(
                title: const Text("Notifications on this day"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notifDocs.docs.map((n) =>
                      Text("${n['title']}: ${n['body']}")).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}
