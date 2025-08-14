import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DriverCalendarScreen extends StatefulWidget {
  const DriverCalendarScreen({Key? key}) : super(key: key);

  @override
  State<DriverCalendarScreen> createState() => _DriverCalendarScreenState();
}

class _DriverCalendarScreenState extends State<DriverCalendarScreen> {
  final driverId = FirebaseAuth.instance.currentUser!.uid;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, Map<String, String>> _dayStatus = {};

  String _morningStatus = 'No record';
  String _eveningStatus = 'No record';
  int _studentCount = 0;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _fetchAttendanceData() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('driverAttendance')
            .where('driverId', isEqualTo: driverId)
            .get();

    final Map<String, Map<String, String>> statusMap = {};
    for (var doc in snapshot.docs) {
      final dateStr = doc['date'] as String;
      final session = doc['session'] as String;
      final status = doc['status'] as String;

      statusMap.putIfAbsent(dateStr, () => {});
      statusMap[dateStr]![session] = status;
    }

    setState(() {
      _dayStatus = statusMap;
    });
  }

  Future<void> _fetchExtraCounts(String dateStr) async {
    final notificationSnap =
        await FirebaseFirestore.instance
            .collection('notifications')
            .where('targetRole', isEqualTo: 'driver')
            .where('date', isEqualTo: dateStr)
            .get();

    final studentSnap =
        await FirebaseFirestore.instance
            .collection('studentAttendance')
            .where('driverId', isEqualTo: driverId)
            .where('date', isEqualTo: dateStr)
            .get();

    setState(() {
      _notificationCount = notificationSnap.docs.length;
      _studentCount = studentSnap.docs.length;
    });
  }

  Color _getDayColor(Map<String, String>? sessions) {
    if (sessions == null || sessions.isEmpty) return Colors.grey.shade600;

    final morning = sessions['morning'];
    final evening = sessions['evening'];

    if (morning == 'holiday' || evening == 'holiday') {
      return Colors.grey.shade200;
    }
    if (morning == 'present' && evening == 'present') {
      return Colors.green.shade700;
    }
    if ((morning == 'leave' || morning == 'absent') &&
        (evening == 'leave' || evening == 'absent')) {
      return Colors.red.shade900;
    }

    return Colors.grey;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    String dateStr = _formatDate(selectedDay);
    final sessions = _dayStatus[dateStr];

    setState(() {
      _morningStatus = sessions?['morning'] ?? 'No record';
      _eveningStatus = sessions?['evening'] ?? 'No record';
    });

    await _fetchExtraCounts(dateStr);
  }

  Widget _buildDayCell(DateTime day, {required bool isSelected}) {
    String dateStr = _formatDate(day);
    final sessions = _dayStatus[dateStr];
    Color bg = _getDayColor(sessions);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border:
            isSelected ? Border.all(color: Colors.deepPurple, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color:
              (bg != Colors.white && bg != Colors.grey.shade200)
                  ? Colors.white
                  : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B60A0), Color(0xFF937BBF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Smart Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Reload Attendance Data",
            onPressed: () async {
              await _fetchAttendanceData();
              if (_selectedDay != null) {
                await _fetchExtraCounts(_formatDate(_selectedDay!));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar data refreshed.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B60A0),
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, isSelected: false);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildDayCell(day, isSelected: true);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDayCell(
                    day,
                    isSelected: isSameDay(day, _selectedDay),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B60A0), Color(0xFF937BBF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Driver Attendance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Morning: $_morningStatus',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Evening: $_eveningStatus',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.people, color: Color(0xFF7B60A0)),
                title: const Text("Students Travelled"),
                subtitle: Text("$_studentCount"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Color(0xFF7B60A0),
                ),
                title: const Text("Total Notifications"),
                subtitle: Text("$_notificationCount"),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildLegendItem(Colors.green.shade700, "Both Present"),
                  _buildLegendItem(Colors.red.shade900, "Both Leave/Absent"),
                  _buildLegendItem(Colors.grey.shade200, "Holiday"),
                  _buildLegendItem(Colors.grey.shade600, "No Record"),
                  _buildLegendItem(Colors.grey, "Mixed Status"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
