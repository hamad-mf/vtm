import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/add_driver_screen.dart';
import 'package:vignan_transportation_management/View/Admin%20module/edit_driver_screen.dart'; // Import the edit screen

class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Drivers", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDriverScreen()),
              );
            },
            icon: Icon(Icons.add, size: 24.w),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff7B61A1).withOpacity(0.1), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Header Stats Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Color(0xff7B61A1),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff7B61A1).withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Driver Management",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Manage all driver profiles and assignments",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Drivers List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: provider.getAllDrivers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff7B61A1),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error loading drivers",
                          style: TextStyle(color: Colors.red, fontSize: 16.sp),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 64.w,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No drivers found",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Add your first driver to get started",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddDriverScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add),
                              label: Text("Add Driver"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff7B61A1),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        return _buildDriverCard(
                          context,
                          doc.id,
                          data,
                          provider,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard(
    BuildContext context,
    String driverId,
    Map<String, dynamic> data,
    DriverController provider,
  ) {
    bool isAssigned = data['isAssigned'] ?? false;
    DateTime? licenseExpiry = data['licenseExpiry']?.toDate();
    bool isLicenseExpiring = false;

    if (licenseExpiry != null) {
      isLicenseExpiring = licenseExpiry.isBefore(
        DateTime.now().add(Duration(days: 30)),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border:
            isLicenseExpiring
                ? Border.all(color: Colors.orange, width: 2)
                : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  height: 50.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isAssigned
                            ? Color(0xff4CAF50).withOpacity(0.1)
                            : Color(0xff7B61A1).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.person,
                    color: isAssigned ? Color(0xff4CAF50) : Color(0xff7B61A1),
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff333333),
                        ),
                      ),
                      Text(
                        "ID: ${data['employeeId'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:
                        isAssigned
                            ? Color(0xff4CAF50).withOpacity(0.1)
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isAssigned ? 'Assigned' : 'Available',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isAssigned ? Color(0xff4CAF50) : Colors.grey.shade600,
                    ),
                  ),
                ),
                // More Options
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Color(0xff7B61A1)),
                              SizedBox(width: 8.w),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8.w),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditDriverScreen(
                                driverId: driverId,
                                driverData: data,
                              ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(
                        context,
                        driverId,
                        data['name'],
                        provider,
                      );
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Warning for license expiry
            if (isLicenseExpiring)
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "License expires on ${licenseExpiry!.day}/${licenseExpiry.month}/${licenseExpiry.year}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (isLicenseExpiring) SizedBox(height: 12.h),

            // Driver Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.phone,
                    "Contact",
                    data['contactNumber'] ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.directions_bus,
                    "Bus ID",
                    data['assignedBusId'] ?? 'N/A',
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.credit_card,
                    "License",
                    "${data['licenseType'] ?? 'N/A'} - ${data['licenseNumber'] ?? 'N/A'}",
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.email,
                    "Email",
                    data['email'] ?? 'N/A',
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // PIN Code display
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.security,
                    "PIN Code",
                    data['pincode'] ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: Container(), // Empty container for spacing
                ),
              ],
            ),

            if (isAssigned && data['assignedRoute'] != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Color(0xff4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.route, color: Color(0xff4CAF50), size: 16.w),
                    SizedBox(width: 8.w),
                    Text(
                      "Assigned to Route",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey.shade600),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color(0xff333333),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String driverId,
    String driverName,
    DriverController provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Driver"),
            content: Text(
              "Are you sure you want to delete $driverName? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await provider.deleteDriver(driverId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.error ?? "Driver deleted successfully",
                      ),
                      backgroundColor:
                          provider.error != null
                              ? Colors.red
                              : Color(0xff4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }
}
