import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParentStudentDetailsScreen extends StatelessWidget {
   final String studentRegNo;
  const ParentStudentDetailsScreen({super.key,required this.studentRegNo});

 @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF7B60A0);
    final TextStyle labelStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp);
    final TextStyle valueStyle = TextStyle(fontSize: 16.sp);

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('registrationNumber', isEqualTo: studentRegNo)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No student found with Registration No: $studentRegNo'));
          }

          final student = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        student['name'] ?? 'No Name',
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    detailRow('Registration No', student['registrationNumber'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Name', student['name'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Address', student['address'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Email', student['email'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Mobile', student['mobileNumber'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Route', student['assignedRoute'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Driver Name', student['assignedDriverName'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow('Fee Status', student['paymentStatus'] ?? 'N/A', labelStyle, valueStyle),
                    detailRow(
                      'Fee Expiry',
                      student['feeExpiryDate'] != null
                          ? (student['feeExpiryDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                          : 'N/A',
                      labelStyle,
                      valueStyle,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget detailRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('$label:', style: labelStyle)),
          Expanded(flex: 5, child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }
}