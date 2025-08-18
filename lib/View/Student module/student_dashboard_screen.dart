import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_custom_bottom_navbar_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_qe_screen.dart';
import 'package:vignan_transportation_management/View/Student%20module/student_route_details.dart';

class StudentDashboardScreen extends StatefulWidget {
  final bool isGraceActive;
  const StudentDashboardScreen({this.isGraceActive = false, super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, dynamic>? studentStatusInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentStatus();
  }

  Future<void> _loadStudentStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final statusInfo = await StudentController.getStudentStatusInfo(uid);
        setState(() {
          studentStatusInfo = statusInfo;
          isLoading = false;
        });
      } catch (e) {
        print('Error loading student status: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildFeeStatusCard() {
    if (isLoading || studentStatusInfo == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final String paymentStatus = studentStatusInfo!['paymentStatus'];
    final DateTime? feeExpiryDate = studentStatusInfo!['feeExpiryDate'];
    final int? daysUntilExpiry = studentStatusInfo!['daysUntilExpiry'];
    final bool isGraceActive = studentStatusInfo!['isGraceActive'];

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (paymentStatus) {
      case 'Paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Fee Paid';
        break;
      case 'Grace':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Grace Period';
        break;
      case 'Pending':
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        statusText = 'Payment Pending';
        break;
      case 'Overdue':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Fee Overdue';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Fee Status',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    _showRefreshDialog();
                  },
                  icon: Icon(Icons.refresh),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Current Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Fee Expiry Information
            if (feeExpiryDate != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Fee Expiry Date: ${feeExpiryDate.day}/${feeExpiryDate.month}/${feeExpiryDate.year}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Days until expiry
              if (daysUntilExpiry != null) ...[
                Row(
                  children: [
                    Icon(
                      daysUntilExpiry > 0
                          ? Icons.schedule
                          : Icons.schedule_send,
                      color:
                          daysUntilExpiry > 7
                              ? Colors.green
                              : daysUntilExpiry > 0
                              ? Colors.orange
                              : Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      daysUntilExpiry > 0
                          ? '$daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'} until expiry'
                          : daysUntilExpiry == 0
                          ? 'Fee expires today!'
                          : 'Fee expired ${(-daysUntilExpiry)} day${(-daysUntilExpiry) == 1 ? '' : 's'} ago',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            daysUntilExpiry > 7
                                ? Colors.green[700]
                                : daysUntilExpiry > 0
                                ? Colors.orange[700]
                                : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Grace period warning
            if (isGraceActive) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are in grace period. Please renew your fee soon.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action button for overdue/pending payments
            if (paymentStatus == 'Overdue' || paymentStatus == 'Pending') ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to payment screen or show payment dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please contact administration for fee payment',
                        ),
                        action: SnackBarAction(label: 'OK', onPressed: () {}),
                      ),
                    );
                  },
                  icon: Icon(Icons.payment),
                  label: Text('Pay Fee'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


      final int? daysUntilExpiry = studentStatusInfo?['daysUntilExpiry'];
  final String paymentStatus = studentStatusInfo?['paymentStatus'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGraceActive
              ? "Dashboard - Grace Period"
              : "Student Dashboard",
        ),
        backgroundColor: widget.isGraceActive ? Colors.orange : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // IconButton(
          //   onPressed: () => _showRefreshDialog(),
          //   icon: Icon(Icons.refresh),
          //   tooltip: 'Refresh Status',
          // ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isstudentLoggedIn', false);
              final authController = Provider.of<LoginController>(
                context,
                listen: false,
              );
              authController.signOut(context);
            },
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           if (studentStatusInfo?['shouldShowBanner'] == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700]),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your transport service renewal is due in "
                      "$daysUntilExpiry day${daysUntilExpiry == 1 ? '' : 's'}. "
                      "Please pay to continue enjoying the service.",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fee Status Card
            _buildFeeStatusCard(),

            // Quick Actions Card
            Card(
              elevation: 4,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // QR Code Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      StudentCustomBottomNavbarScreen(
                                        initialIndex: 2,
                                      ),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(Icons.qr_code),
                        label: Text('View My QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Route Info Button (placeholder)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      StudentRouteDetails(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(Icons.directions_bus),
                        label: Text('View Route Info'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Profile Button (placeholder)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      StudentCustomBottomNavbarScreen(
                                        initialIndex: 3,
                                      ),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(Icons.person),
                        label: Text('View Profile'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefreshDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Refresh Status'),
          content: Text('Do you want to check for the latest fee status?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = true;
                });
                _loadStudentStatus();
              },
              child: Text('Refresh'),
            ),
          ],
        );
      },
    );
  }
}
