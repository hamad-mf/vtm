import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/route_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/add_route_screen.dart';

class RouteListScreen extends StatelessWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouteController>(context);
    final driverController = Provider.of<DriverController>(context, listen: false);
final routeController = Provider.of<RouteController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Routes", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRouteScreen()),
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
                        Icons.route,
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
                            "Route Management",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Manage all routes and assignments",
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

              // Routes List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: provider.getAllRoutes(),
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
                          "Error loading routes",
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
                              Icons.route_outlined,
                              size: 64.w,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No routes found",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Add your first route to get started",
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
                                    builder: (context) => AddRouteScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add),
                              label: Text("Add Route"),
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

                        return _buildRouteCard(
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

  Widget _buildRouteCard(
    BuildContext context,
    String routeId,
    Map<String, dynamic> data,
    RouteController provider,
  ) {

    final driverController = Provider.of<DriverController>(context, listen: false);
final routeController = Provider.of<RouteController>(context, listen: false);
    bool isActive = data['isActive'] ?? true;
    bool hasDriver = data['assignedDriverId'] != null;
    String driverName = data['assignedDriverName'] ?? 'Unassigned';
    
    Map<String, dynamic> startPoint = data['startPoint'] ?? {};
    Map<String, dynamic> endPoint = data['endPoint'] ?? {};
    List<dynamic> stops = data['stops'] ?? [];
    List<dynamic> timings = data['timings'] ?? [];

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
        border: !isActive ? Border.all(color: Colors.orange, width: 2) : null,
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
                    color: isActive
                        ? Color(0xff4CAF50).withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.route,
                    color: isActive ? Color(0xff4CAF50) : Colors.orange,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['routeName'] ?? 'Unknown Route',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff333333),
                        ),
                      ),
                      Text(
                        "Frequency: ${data['frequency'] ?? 'N/A'}",
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
                    color: isActive
                        ? Color(0xff4CAF50).withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Color(0xff4CAF50) : Colors.orange,
                    ),
                  ),
                ),
                // More Options
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.pause : Icons.play_arrow,
                            color: isActive ? Colors.orange : Color(0xff4CAF50),
                          ),
                          SizedBox(width: 8.w),
                          Text(isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
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
                    if (value == 'delete') {
                      _showDeleteConfirmation(
                        context,
                        routeId,
                        data['routeName'],
                        provider,
                      );
                    } else if (value == 'toggle') {
                      _toggleRouteStatus(context, routeId, !isActive, provider);
                    }
                    // Add edit functionality here
                  },
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Warning for inactive routes
            if (!isActive)
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
                        "This route is currently inactive",
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

            if (!isActive) SizedBox(height: 12.h),

            // Route Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.location_on,
                    "Start Point",
                    startPoint['name'] ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.flag,
                    "End Point",
                    endPoint['name'] ?? 'N/A',
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.stop_circle,
                    "Stops",
                    "${stops.length} stops",
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.schedule,
                    "Timings",
                    "${timings.length} timings",
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Driver Assignment Section
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: hasDriver
                    ? Color(0xff4CAF50).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasDriver
                      ? Color(0xff4CAF50).withOpacity(0.3)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasDriver ? Icons.person : Icons.person_off,
                    color: hasDriver ? Color(0xff4CAF50) : Colors.grey.shade600,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      hasDriver ? "Driver: $driverName" : "No driver assigned",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: hasDriver
                            ? Color(0xff4CAF50)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  if (!hasDriver)
                    TextButton(
                      onPressed: () {
                        // Navigate to assign driver screen or show dialog
                    _showDriverAssignmentDialog(context, routeId, routeController, driverController);


                      },
                      child: Text(
                        "Assign",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xff7B61A1),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Show timings if available
            if (timings.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Color(0xff7B61A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Color(0xff7B61A1), size: 16.w),
                        SizedBox(width: 8.w),
                        Text(
                          "Route Timings",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff7B61A1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: timings.take(3).map((timing) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff7B61A1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: Color(0xff7B61A1).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            timing.toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Color(0xff7B61A1),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (timings.length > 3)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          "+${timings.length - 3} more",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
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
    String routeId,
    String routeName,
    RouteController provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Route"),
        content: Text(
          "Are you sure you want to delete '$routeName'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteRoute(routeId);

              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.error ?? "Route deleted successfully",
                  ),
                  backgroundColor: provider.error != null
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

  void _toggleRouteStatus(
    BuildContext context,
    String routeId,
    bool newStatus,
    RouteController provider,
  ) async {
    await provider.toggleRouteStatus(routeId, newStatus);
    
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.error ?? "Route ${newStatus ? 'activated' : 'deactivated'} successfully",
        ),
        backgroundColor: provider.error != null
            ? Colors.red
            : Color(0xff4CAF50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

void _showDriverAssignmentDialog(
  BuildContext context,
  String routeId,
  RouteController routeController,
  DriverController driverController,
) {
  showDialog(
    context: context,
    builder: (_) {
      String? selectedDriverId;
      String? selectedDriverName;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Assign Driver'),
            content: Container(
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream: driverController.getAvailableDrivers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final drivers = snapshot.data?.docs ?? [];
                  if (drivers.isEmpty) {
                    return Text('No available drivers found');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driverData =
                          drivers[index].data() as Map<String, dynamic>;
                      final driverName = driverData['name'] ?? 'Unnamed';
                      final driverId = drivers[index].id;

                      return RadioListTile<String>(
                        title: Text(driverName),
                        value: driverId,
                        groupValue: selectedDriverId,
                        onChanged: (value) {
                          setState(() {
                            selectedDriverId = value;
                            selectedDriverName = driverName;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Assign'),
                onPressed: selectedDriverId == null
                    ? null
                    : () async {
                        try {
                          await routeController.assignDriverToRoute(
                            routeId,
                            selectedDriverId!,
                            selectedDriverName!,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Driver assigned successfully'),
                              backgroundColor: Color(0xff4CAF50),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to assign driver: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
              ),
            ],
          );
        },
      );
    },
  );
}


  }
