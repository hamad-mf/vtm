import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParentDriverDetailsScreen extends StatelessWidget {
  final String driverId;
  const ParentDriverDetailsScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF7B60A0);
    final TextStyle labelStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp);
    final TextStyle valueStyle = TextStyle(fontSize: 16.sp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Details'),
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers').doc(driverId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No driver details found for ID: $driverId'));
          }

          final driver = snapshot.data!.data() as Map<String, dynamic>;

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
                        driver['name'] ?? 'Driver Name',
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    infoRow('Employee ID', driver['employeeId'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('Contact Number', driver['contactNumber'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('Email', driver['email'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('License Number', driver['licenseNumber'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('License Type', driver['licenseType'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('License Expiry', driver['licenseExpiry'] != null
                        ? (driver['licenseExpiry'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                        : 'N/A', labelStyle, valueStyle),
                    infoRow('Pincode', driver['pincode'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('Assigned Bus', driver['assignedBusId'] ?? 'N/A', labelStyle, valueStyle),
                    infoRow('Assigned Route', driver['assignedRoute'] ?? 'N/A', labelStyle, valueStyle),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('$label:', style: labelStyle)),
          Expanded(flex: 5, child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }
}