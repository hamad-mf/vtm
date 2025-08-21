import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaffRouteInfoScreen extends StatelessWidget {
  final String assignedRouteId;

  const StaffRouteInfoScreen({Key? key, required this.assignedRouteId})
    : super(key: key);
  final baseColor = const Color(0xFF7B60A0);
  @override
  Widget build(BuildContext context) {
    final routeStream =
        FirebaseFirestore.instance
            .collection('routes')
            .doc(assignedRouteId)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseColor,
        title: Text(
          "Route Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: routeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No route information available."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String routeName = data['routeName'] ?? 'Unnamed Route';
          final String driverName =
              data['assignedDriverName'] ?? 'Unknown Driver';
          final String vehicleId = data['assignedVehicleId'] ?? 'N/A';
          final String frequency = data['frequency'] ?? 'N/A';
          final bool isActive = data['isActive'] ?? false;

          final startPoint = data['startPoint'] as Map<String, dynamic>? ?? {};
          final endPoint = data['endPoint'] as Map<String, dynamic>? ?? {};

          final List<dynamic> stops = data['stops'] ?? [];
          final List<dynamic> timings = data['timings'] ?? [];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card with main details
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [baseColor, baseColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      infoRow(Icons.person_outline, "Driver", driverName),
                      infoRow(Icons.directions_bus, "Vehicle", vehicleId),
                      infoRow(Icons.repeat, "Frequency", frequency),
                      infoRow(
                        Icons.toggle_on,
                        "Active",
                        isActive ? "Yes" : "No",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Start and End Point Cards
                Row(
                  children: [
                    Expanded(child: locationCard("Start Point", startPoint)),
                    SizedBox(width: 16.w),
                    Expanded(child: locationCard("End Point", endPoint)),
                  ],
                ),

                SizedBox(height: 20.h),

                // Stops List
                Text(
                  "Stops (${stops.length})",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
                const Divider(thickness: 2),
                ...stops.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  dynamic stop = entry.value;
                  String stopName = "";
                  if (stop is Map) {
                    stopName = stop['name'] ?? 'Stop $idx';
                  } else if (stop is String) {
                    stopName = stop;
                  } else {
                    stopName = 'Stop $idx';
                  }
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: baseColor,
                      child: Text(
                        '$idx',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(stopName, style: TextStyle(fontSize: 16.sp)),
                  );
                }),

                SizedBox(height: 20.h),

                // Timings
                Text(
                  "Timings",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
                const Divider(thickness: 2),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                        timings.map<Widget>((t) {
                          final timeText = t.toString().replaceAll('"', '');
                          return Chip(
                            label: Text(
                              timeText,
                              style: TextStyle(color: baseColor),
                            ),
                            backgroundColor: baseColor.withOpacity(0.2),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            "$label:",
            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget locationCard(String title, Map<String, dynamic> point) {
    final lat = point['latitude']?.toString() ?? 'N/A';
    final lng = point['longitude']?.toString() ?? 'N/A';
    final name = point['name'] ?? title;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: baseColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4.h),
          Text("Lat: $lat", style: TextStyle(color: Colors.grey[600])),
          Text("Lng: $lng", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
