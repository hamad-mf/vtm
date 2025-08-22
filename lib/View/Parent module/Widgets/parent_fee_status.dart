import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParentFeeStatus extends StatefulWidget {
  final String studentId;
  const ParentFeeStatus({Key? key, required this.studentId}) : super(key: key);

  @override
  _ParentFeeStatusState createState() => _ParentFeeStatusState();
}

class _ParentFeeStatusState extends State<ParentFeeStatus> {
  Map<String, dynamic>? feeData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeInfo();
  }

  Future<void> _fetchFeeInfo() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(widget.studentId)
              .get();
      if (doc.exists) {
        setState(() {
          feeData = doc.data();
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print('Error fetching fee info: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Card(
        margin: EdgeInsets.all(19.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (feeData == null) {
      return SizedBox.shrink(); // or show a message "No fee info available"
    }

    final paymentStatus = feeData!['paymentStatus'] ?? 'Unknown';
    final lastPaidDateTs = feeData!['updatedAt'] as Timestamp?;
    final lastPaidDate = lastPaidDateTs?.toDate();
    final renewalDatTs = feeData!['feeExpiryDate'] as Timestamp?;
    final renewalDate = renewalDatTs?.toDate();

    Color statusColor;
    switch (paymentStatus.toString().toLowerCase()) {
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'overdue':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.all(16.w),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fee Status',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Payment Status: $paymentStatus',
              style: TextStyle(fontSize: 16.sp),
            ),
            if (lastPaidDate != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Last Payment Date: ${lastPaidDate.day}/${lastPaidDate.month}/${lastPaidDate.year}',
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
            if (renewalDate != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Next fee renewal date: ${renewalDate.day}/${renewalDate.month}/${renewalDate.year}',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
