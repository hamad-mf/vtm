import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math' show pi;

class ParentStudentAttendanceScreen extends StatefulWidget {
  const ParentStudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<ParentStudentAttendanceScreen> createState() =>
      _ParentStudentAttendanceScreenState();
}

class _ParentStudentAttendanceScreenState
    extends State<ParentStudentAttendanceScreen> {
  String? _linkedStudentId; // Actual student UID
  String? _linkedStudentRegNo; // Registration number

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, Map<String, String>> _dayTravelStatus = {};

  String _morningTravelStatus = 'No record';
  String _eveningTravelStatus = 'No record';
  String _assignedRoute = 'Not assigned';
  String _driverName = 'Unknown';
  int _totalTravelDays = 0;

  bool _loading = true;
  bool _noStudent = false;

  @override
  void initState() {
    super.initState();
    _fetchLinkedStudent();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _fetchLinkedStudent() async {
    setState(() {
      _loading = true;
      _noStudent = false;
    });
    try {
      final parentUid = FirebaseAuth.instance.currentUser!.uid;
      final parentDoc =
          await FirebaseFirestore.instance
              .collection('parents')
              .doc(parentUid)
              .get();
      if (!parentDoc.exists) {
        setState(() {
          _noStudent = true;
          _loading = false;
        });
        return;
      }
      final parentData = parentDoc.data()!;
      _linkedStudentRegNo = parentData['StudentRegNo'];

      if (_linkedStudentRegNo == null || _linkedStudentRegNo!.isEmpty) {
        setState(() {
          _noStudent = true;
          _loading = false;
        });
        return;
      }

      final studentQuery =
          await FirebaseFirestore.instance
              .collection('students')
              .where('registrationNumber', isEqualTo: _linkedStudentRegNo)
              .limit(1)
              .get();

      if (studentQuery.docs.isEmpty) {
        setState(() {
          _noStudent = true;
          _loading = false;
        });
        return;
      }
      final studentData = studentQuery.docs.first.data();

      setState(() {
        _linkedStudentId = studentData['studentId'];
        _loading = false;
      });

      await _fetchStudentInfo();
      await _fetchTravelData();
    } catch (e) {
      setState(() {
        _noStudent = true;
        _loading = false;
      });
      print('Error fetching linked student: $e');
    }
  }

  Future<void> _fetchStudentInfo() async {
    if (_linkedStudentId == null) return;
    try {
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(_linkedStudentId)
              .get();

      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _assignedRoute = data['assignedRoute'] ?? 'Not assigned';
          _driverName = data['assignedDriverName'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching student info: $e');
    }
  }

  Future<void> _fetchTravelData() async {
    if (_linkedStudentId == null) return;
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('studentAttendance')
              .where('studentId', isEqualTo: _linkedStudentId)
              .get();

      final Map<String, Map<String, String>> travelStatusMap = {};
      final Set<String> datesWithTravel = {};

      for (var doc in snapshot.docs) {
        final dateStr = doc['date'] as String;
        final session = doc['session'] as String;
        final status = doc['status'] as String;

        travelStatusMap.putIfAbsent(dateStr, () => {});
        travelStatusMap[dateStr]![session.toLowerCase()] = status.toLowerCase();

        if (status.toLowerCase() == 'present') {
          datesWithTravel.add(dateStr);
        }
      }

      setState(() {
        _dayTravelStatus = travelStatusMap;
        _totalTravelDays = datesWithTravel.length;
      });
    } catch (e) {
      print('Error fetching travel data: $e');
    }
  }

  Future<void> _fetchDayDetails(String dateStr) async {
    final sessions = _dayTravelStatus[dateStr];
    setState(() {
      _morningTravelStatus = _getStatusDisplay(sessions?['morning']);
      _eveningTravelStatus = _getStatusDisplay(sessions?['evening']);
    });
  }

  String _getStatusDisplay(String? status) {
    if (status == null) return 'No record';
    switch (status.toLowerCase()) {
      case 'present':
        return 'Travelled';
      case 'absent':
        return 'Did not travel';
      case 'holiday':
        return 'Holiday';
      case 'cancelled':
        return 'Route cancelled';
      default:
        return 'No record';
    }
  }

  Color _getDayColor(Map<String, String>? sessions) {
    if (sessions == null || sessions.isEmpty) return Colors.grey.shade400;

    final morning = sessions['morning'];
    final evening = sessions['evening'];

    if (morning == 'holiday' ||
        evening == 'holiday' ||
        morning == 'cancelled' ||
        evening == 'cancelled') {
      return Colors.grey.shade300;
    }
    if (morning == 'present' && evening == 'present') {
      return Colors.green.shade600;
    }
    if ((morning == 'absent' || morning == null) &&
        (evening == 'absent' || evening == null)) {
      return Colors.red.shade600;
    }
    return Colors.orange.shade400;
  }

  bool _isMixedStatus(Map<String, String>? sessions) {
    if (sessions == null || sessions.isEmpty) return false;

    final morning = sessions['morning'];
    final evening = sessions['evening'];

    return (morning == 'present' && evening != 'present') ||
        (morning != 'present' && evening == 'present');
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    String dateStr = _formatDate(selectedDay);
    await _fetchDayDetails(dateStr);
  }

  Widget _buildDayCell(DateTime day, {required bool isSelected}) {
    String dateStr = _formatDate(day);
    final sessions = _dayTravelStatus[dateStr];
    bool isMixed = _isMixedStatus(sessions);
    Color bg = _getDayColor(sessions);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            isSelected ? Border.all(color: Colors.deepPurple, width: 3) : null,
      ),
      child:
          isMixed
              ? CustomPaint(
                size: const Size(40, 40),
                painter: HalfCirclePainter(
                  leftColor:
                      sessions!['morning'] == 'present'
                          ? Colors.green.shade600
                          : Colors.grey.shade400,
                  rightColor:
                      sessions['evening'] == 'present'
                          ? Colors.green.shade600
                          : Colors.grey.shade400,
                  isSelected: isSelected,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              : Container(
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color:
                        (bg == Colors.grey.shade300 ||
                                bg == Colors.grey.shade400)
                            ? Colors.black87
                            : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
    );
  }

  Widget _buildLegendItem(Widget colorIndicator, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        colorIndicator,
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildCircleLegend(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildHalfCircleLegend(Color leftColor, Color rightColor) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(
        painter: HalfCirclePainter(
          leftColor: leftColor,
          rightColor: rightColor,
          isSelected: false,
        ),
      ),
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
          'Travel Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Reload Travel Data",
            onPressed: () async {
              await _fetchLinkedStudent();
              if (_selectedDay != null) {
                await _fetchDayDetails(_formatDate(_selectedDay!));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Travel data refreshed.')),
              );
            },
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _noStudent
              ? const Center(child: Text("Linked student not found."))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Calendar
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
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
                    // Daily Travel Status
                    if (_selectedDay != null)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Travel Status - ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Morning: $_morningTravelStatus',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Evening: $_eveningTravelStatus',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    // Route Information
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.route,
                          color: Color(0xFF7B60A0),
                        ),
                        title: const Text("Assigned Route"),
                        subtitle: Text(_assignedRoute),
                      ),
                    ),
                    // Driver Information
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Color(0xFF7B60A0),
                        ),
                        title: const Text("Driver"),
                        subtitle: Text(_driverName),
                      ),
                    ),
                    // Total Travel Days
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.confirmation_number,
                          color: Color(0xFF7B60A0),
                        ),
                        title: const Text("Total Travel Days"),
                        subtitle: Text("$_totalTravelDays days"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Travel Status Legend',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF7B60A0),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _buildLegendItem(
                                _buildCircleLegend(Colors.green.shade600),
                                "Both shifts",
                              ),
                              _buildLegendItem(
                                _buildCircleLegend(Colors.red.shade600),
                                "No travel",
                              ),
                              _buildLegendItem(
                                _buildHalfCircleLegend(
                                  Colors.green.shade600,
                                  Colors.grey.shade400,
                                ),
                                "Morning only",
                              ),
                              _buildLegendItem(
                                _buildHalfCircleLegend(
                                  Colors.grey.shade400,
                                  Colors.green.shade600,
                                ),
                                "Evening only",
                              ),
                              _buildLegendItem(
                                _buildCircleLegend(Colors.grey.shade300),
                                "Holiday/Cancelled",
                              ),
                              _buildLegendItem(
                                _buildCircleLegend(Colors.grey.shade400),
                                "No record",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
    );
  }
}

// Custom painter for half circles
class HalfCirclePainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;
  final bool isSelected;

  HalfCirclePainter({
    required this.leftColor,
    required this.rightColor,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint leftPaint = Paint()..color = leftColor;
    final Paint rightPaint = Paint()..color = rightColor;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // Draw left half circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      pi, // Half circle (180 degrees)
      true,
      leftPaint,
    );

    // Draw right half circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2, // Start from bottom
      pi, // Half circle (180 degrees)
      true,
      rightPaint,
    );

    // Draw selection border if selected
    if (isSelected) {
      final Paint borderPaint =
          Paint()
            ..color = Colors.deepPurple
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;

      canvas.drawCircle(center, radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
