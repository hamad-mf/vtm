import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverAttendanceCalendarScreen extends StatefulWidget {
  final String driverId; // Pass this UID from your selection screen
  const DriverAttendanceCalendarScreen({required this.driverId, Key? key})
    : super(key: key);

  @override
  State<DriverAttendanceCalendarScreen> createState() =>
      _DriverAttendanceCalendarScreenState();
}

class _DriverAttendanceCalendarScreenState
    extends State<DriverAttendanceCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Maps dates to attendance status for calendar coloring
  Map<DateTime, String> _attendanceMap = {};

  @override
  Widget build(BuildContext context) {
    // Quick string converter for date in Firestore format
    String _dateKey(DateTime date) =>
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("Driver Attendance Calendar")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('driverAttendance')
                .where('driverId', isEqualTo: widget.driverId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          // Build attendance map for calendar markers
          _attendanceMap.clear();
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            try {
              DateTime date = DateTime.parse(data['date']);
              _attendanceMap[DateTime(date.year, date.month, date.day)] =
                  data['status']; // present/leave
            } catch (_) {}
          }

          // Gather daily attendance records for selected day
          List<Map<String, dynamic>> dayRecords =
              snapshot.data!.docs
                  .where((doc) => doc['date'] == _dateKey(_selectedDay))
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

          return Column(
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    String? status =
                        _attendanceMap[DateTime(day.year, day.month, day.day)];
                    if (status == 'present') {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    } else if (status == 'leave') {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return null; // Keep default styling (gray)
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Attendance Details for ${_dateKey(_selectedDay)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Show attendance details for selected day
              Expanded(
                child:
                    dayRecords.isEmpty
                        ? Center(
                          child: Text("No attendance records for this date."),
                        )
                        : ListView.builder(
                          itemCount: dayRecords.length,
                          itemBuilder: (context, index) {
                            final rec = dayRecords[index];
                            return ListTile(
                              leading: Icon(
                                rec['session'] == 'morning'
                                    ? Icons.wb_sunny_outlined
                                    : Icons.nightlight_round,
                              ),
                              title: Text(
                                "Session: ${rec['session']?.toString().capitalize() ?? ''}",
                              ),
                              subtitle: Text("Status: ${rec['status'] ?? ''}"),
                              trailing:
                                  rec['status'] == 'present'
                                      ? Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : Icon(Icons.cancel, color: Colors.red),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// helper extension to capitalize session string
extension StringCasing on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
