import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String? error;

  // Get driver attendance by driverId
  Stream<QuerySnapshot<Map<String, dynamic>>> getDriverAttendance(String driverId) {
    return _firestore
        .collection('driverAttendance')
        .where('driverId', isEqualTo: driverId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get student attendance filtered by route/date/session
  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentAttendance({
    String? routeId,
    DateTime? date,
    String? session,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('studentAttendance');

    if (routeId != null) {
      query = query.where('routeId', isEqualTo: routeId);
    }
    if (date != null) {
      final dateString = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
      query = query.where('date', isEqualTo: dateString);
    }
    if (session != null) {
      query = query.where('session', isEqualTo: session);
    }

    return query.orderBy('date', descending: true).snapshots();
  }
}
