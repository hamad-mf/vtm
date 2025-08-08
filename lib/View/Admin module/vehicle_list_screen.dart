import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/vehicle_controller.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Vehicles", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff7B61A1).withOpacity(0.1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Header
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
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(Icons.directions_bus, color: Colors.white, size: 24.w),
                    ),
                    SizedBox(width: 15.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vehicle Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          "Manage your fleet of buses and vans",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Vehicle List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: provider.getAllVehicles(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Color(0xff7B61A1)));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error loading vehicles",
                          style: TextStyle(color: Colors.red, fontSize: 16.sp),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bus, size: 64.w, color: Colors.grey.shade400),
                            SizedBox(height: 12.h),
                            Text("No vehicles found", style: TextStyle(fontSize: 18.sp, color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return _buildVehicleCard(context, docs[index].id, data, provider);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Vehicle Card
  Widget _buildVehicleCard(BuildContext context, String vehicleId, Map<String, dynamic> data, VehicleController provider) {
    bool isAssignedToRoute = data['assignedRouteId'] != null;
    bool isActive = (data['status'] ?? "Active") == "Active";

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
          ),
        ],
        border: !isActive ? Border.all(color: Colors.orange, width: 2) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: isActive ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  child: Icon(Icons.directions_bus, color: isActive ? Colors.green : Colors.orange),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    "${data['busId']} - ${data['vehicleNumber'] ?? ''}",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp, color: Color(0xff333333)),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "toggle",
                      child: Row(
                        children: [
                          Icon(isActive ? Icons.pause : Icons.play_arrow, color: isActive ? Colors.orange : Colors.green),
                          SizedBox(width: 8.w),
                          Text(isActive ? "Deactivate" : "Activate"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xff7B61A1)),
                          SizedBox(width: 8.w),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      enabled: !isAssignedToRoute, // 🚫 disable if assigned
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: isAssignedToRoute ? Colors.grey : Colors.red),
                          SizedBox(width: 8.w),
                          Text(isAssignedToRoute ? "Assigned – Can't delete" : "Delete"),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == "delete") {
                      _showDeleteConfirmation(context, vehicleId, provider);
                    } else if (value == "toggle") {
                      String newStatus = isActive ? "Inactive" : "Active";
                      await provider.updateVehicle(vehicleId, {'status': newStatus});
                    }
                  },
                )
              ],
            ),
            SizedBox(height: 8.h),

            // Vehicle Info Rows
            _buildDetail(Icons.category, "Type", data['type'] ?? "N/A"),
            _buildDetail(Icons.event_seat, "Capacity", "${data['capacity'] ?? 'N/A'} seats"),
            _buildDetail(Icons.date_range, "Reg Expiry", _formatDate(data['registrationExpiry'])),
            _buildDetail(Icons.security, "Insurance Expiry", _formatDate(data['insuranceExpiry'])),
            if (isAssignedToRoute)
              _buildDetail(Icons.route, "Assigned Route ID", data['assignedRouteId']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 16.w),
          SizedBox(width: 6.w),
          Text("$label: ", style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.sp, color: Color(0xff333333))),
          )
        ],
      ),
    );
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return "N/A";
    DateTime d = ts.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }

  void _showDeleteConfirmation(BuildContext context, String vehicleId, VehicleController provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Vehicle"),
        content: Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteVehicle(vehicleId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.error ?? "Vehicle deleted successfully"),
                  backgroundColor: provider.error != null ? Colors.red : Colors.green),
              );
            },
            child: Text("Delete"),
          )
        ],
      ),
    );
  }
}
