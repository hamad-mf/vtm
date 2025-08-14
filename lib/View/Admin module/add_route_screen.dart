import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/route_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize form data map with empty values
    _formData['routeName'] = '';
    _formData['startPointName'] = '';
    _formData['endPointName'] = '';
    _formData['frequency'] = '';
  }

  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  // Stop management
  List<Map<String, dynamic>> stops = [];
  List<String> timings = [];

  // Driver assignment
  String? selectedDriverId;
  String? selectedDriverName;

  // Controllers for coordinates
  final TextEditingController _startLatController = TextEditingController();
  final TextEditingController _startLngController = TextEditingController();
  final TextEditingController _endLatController = TextEditingController();
  final TextEditingController _endLngController = TextEditingController();

  @override
  void dispose() {
    _startLatController.dispose();
    _startLngController.dispose();
    _endLatController.dispose();
    _endLngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteController>(context);
    final driverProvider = Provider.of<DriverController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Route", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Header Card
                _buildHeaderCard(),

                SizedBox(height: 20.h),

                // Route Basic Information
                _buildSectionCard("Route Information", Icons.route, [
                  buildField(
                    "Route Name",
                    "routeName",
                    Icons.directions_outlined,
                  ),
                  SizedBox(height: 16.h),
                  buildDropdownField(
                    "Frequency",
                    "frequency",
                    Icons.schedule_outlined,
                    ['Daily', 'Weekly', 'Bi-weekly', 'Monthly'],
                  ),
                ]),

                SizedBox(height: 20.h),

                // Start Point Information
                _buildSectionCard("Start Point", Icons.location_on, [
                  buildField(
                    "Start Point Name",
                    "startPointName",
                    Icons.place_outlined,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: buildCoordinateField(
                          "Latitude",
                          _startLatController,
                          Icons.my_location_outlined,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: buildCoordinateField(
                          "Longitude",
                          _startLngController,
                          Icons.my_location_outlined,
                        ),
                      ),
                    ],
                  ),
                ]),

                SizedBox(height: 20.h),

                // End Point Information
                _buildSectionCard("End Point", Icons.flag, [
                  buildField(
                    "End Point Name",
                    "endPointName",
                    Icons.flag_outlined,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: buildCoordinateField(
                          "Latitude",
                          _endLatController,
                          Icons.my_location_outlined,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: buildCoordinateField(
                          "Longitude",
                          _endLngController,
                          Icons.my_location_outlined,
                        ),
                      ),
                    ],
                  ),
                ]),

                SizedBox(height: 20.h),

                // Intermediate Stops 
                // _buildStopsSection(),
                SizedBox(height: 20.h),

                // Timings Section
                _buildTimingsSection(),

                SizedBox(height: 20.h),

                // Driver Assignment Section
                _buildDriverAssignmentSection(driverProvider),

                SizedBox(height: 30.h),

                // Submit Button
                _buildSubmitButton(routeProvider),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
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
            child: Icon(Icons.add_road, color: Colors.white, size: 24.w),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Route Creation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Configure route details and stops",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xff7B61A1), size: 20.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7B61A1),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStopsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stop_circle, color: Color(0xff7B61A1), size: 20.w),
              SizedBox(width: 8.w),
              Text(
                "Intermediate Stops",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7B61A1),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: _addStop,
                icon: Icon(Icons.add_circle, color: Color(0xff4CAF50)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (stops.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  "No stops added yet. Tap + to add stops.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            )
          else
            ...stops.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> stop = entry.value;
              return _buildStopItem(index, stop);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildStopItem(int index, Map<String, dynamic> stop) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: Color(0xff7B61A1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop['name'] ?? 'Stop ${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333),
                  ),
                ),
                Text(
                  "Lat: ${stop['latitude']}, Lng: ${stop['longitude']}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeStop(index),
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Color(0xff7B61A1), size: 20.w),
              SizedBox(width: 8.w),
              Text(
                "Route Timings",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7B61A1),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: _addTiming,
                icon: Icon(Icons.add_circle, color: Color(0xff4CAF50)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (timings.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  "No timings added yet. Tap + to add timings.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            )
          else
            ...timings.asMap().entries.map((entry) {
              int index = entry.key;
              String timing = entry.value;
              return _buildTimingItem(index, timing);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimingItem(int index, String timing) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Color(0xff7B61A1), size: 16.w),
          SizedBox(width: 8.w),
          Text(
            timing,
            style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
          ),
          Spacer(),
          IconButton(
            onPressed: () => _removeTiming(index),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
              size: 18.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverAssignmentSection(DriverController driverProvider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin, color: Color(0xff7B61A1), size: 20.w),
              SizedBox(width: 8.w),
              Text(
                "Driver Assignment",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7B61A1),
                ),
              ),
              Spacer(),

              // Debug button - remove this in production
            ],
          ),
          SizedBox(height: 16.h),
          StreamBuilder<QuerySnapshot>(
            stream: driverProvider.getAvailableDrivers(),
            builder: (context, snapshot) {
              // Debug information
              print('StreamBuilder state: ${snapshot.connectionState}');
              print('Has data: ${snapshot.hasData}');
              print('Has error: ${snapshot.hasError}');
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
              }
              if (snapshot.hasData) {
                print('Documents count: ${snapshot.data!.docs.length}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xff7B61A1)),
                        SizedBox(height: 8.h),
                        Text(
                          "Loading drivers...",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 24.w),
                      SizedBox(height: 8.h),
                      Text(
                        "Error loading drivers:",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${snapshot.error}",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      "No data received from server...",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                );
              }

              final drivers = snapshot.data!.docs;

              // Additional debug info
              print('Processing ${drivers.length} drivers');
              for (var driver in drivers) {
                Map<String, dynamic> data =
                    driver.data() as Map<String, dynamic>;
                print(
                  'Driver: ${data['name']}, isAssigned: ${data['isAssigned']}',
                );
              }

              if (drivers.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off,
                        color: Colors.grey.shade400,
                        size: 32.w,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "No available drivers found.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "All drivers may be assigned to routes.",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Color(0xffF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String?>(
                    // Note: String? to allow null
                    isExpanded: true,
                    hint: Text(
                      "Select Driver (${drivers.length} available)",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null, // Explicitly null
                        child: Text(
                          "No driver assigned",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ...drivers.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String?>(
                          // String? to match the type
                          value: doc.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${data['name'] ?? 'Unknown'} (${data['employeeId'] ?? 'No ID'})",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "License: ${data['licenseType'] ?? 'N/A'} | Bus: ${data['assignedBusId'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    value: selectedDriverId,
                    onChanged: (value) {
                      setState(() {
                        selectedDriverId = value;
                        if (value != null) {
                          final driverDoc = drivers.firstWhere(
                            (doc) => doc.id == value,
                          );
                          selectedDriverName =
                              (driverDoc.data()
                                  as Map<String, dynamic>)['name'];
                          print(
                            'Selected driver: $selectedDriverName (ID: $selectedDriverId)',
                          );
                        } else {
                          selectedDriverName = null;
                          print('No driver selected');
                        }
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 56.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Color(0xffF8F9FA),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: 60.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24.w,
                      iconEnabledColor: Color(0xff7B61A1),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(RouteController routeProvider) {
    return Container(
      width: double.infinity,
      height: 56.h,
      child:
          routeProvider.isLoading
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Color(0xff4CAF50).withOpacity(0.7),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
              : ElevatedButton(
                onPressed: () async {
                  // Debug current form data
                  print('=== FORM DATA BEFORE VALIDATION ===');
                  print('Route Name: "${_formData['routeName']}"');
                  print('Start Point: "${_formData['startPointName']}"');
                  print('End Point: "${_formData['endPointName']}"');
                  print('Frequency: "${_formData['frequency']}"');
                  print('Start Lat: "${_startLatController.text}"');
                  print('Start Lng: "${_startLngController.text}"');
                  print('End Lat: "${_endLatController.text}"');
                  print('End Lng: "${_endLngController.text}"');

                  final formState = _formKey.currentState;
                  if (formState == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Form initialization error. Please try again.",
                        ),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    return;
                  }

                  // Save form data first
                  formState.save();

                  // Debug form data after save
                  print('=== FORM DATA AFTER SAVE ===');
                  print('Route Name: "${_formData['routeName']}"');
                  print('Start Point: "${_formData['startPointName']}"');
                  print('End Point: "${_formData['endPointName']}"');
                  print('Frequency: "${_formData['frequency']}"');

                  // Validate form
                  bool isFormValid = formState.validate();
                  bool areCoordsValid = _validateCoordinates();

                  if (!isFormValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fill all required fields"),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    return;
                  }

                  if (!areCoordsValid) {
                    return; // Error message already shown in _validateCoordinates
                  }

                  // Additional validation for required fields
                  if (_formData['routeName']?.trim().isEmpty == true ||
                      _formData['startPointName']?.trim().isEmpty == true ||
                      _formData['endPointName']?.trim().isEmpty == true ||
                      _formData['frequency']?.trim().isEmpty == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fill all required fields"),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    return;
                  }

                  // Parse coordinates
                  double? startLat, startLng, endLat, endLng;
                  try {
                    startLat = double.parse(_startLatController.text.trim());
                    startLng = double.parse(_startLngController.text.trim());
                    endLat = double.parse(_endLatController.text.trim());
                    endLng = double.parse(_endLngController.text.trim());
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Invalid coordinate values"),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    return;
                  }

                  // Validate coordinate ranges
                  if (startLat < -90 ||
                      startLat > 90 ||
                      endLat < -90 ||
                      endLat > 90) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Latitude must be between -90 and 90 degrees",
                        ),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    return;
                  }

                  if (startLng < -180 ||
                      startLng > 180 ||
                      endLng < -180 ||
                      endLng > 180) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Longitude must be between -180 and 180 degrees",
                        ),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    return;
                  }

                  // All validations passed - create route
                  try {
                    await routeProvider.addRoute(
                      routeName: _formData['routeName']!.trim(),
                      startPointName: _formData['startPointName']!.trim(),
                      startLatitude: startLat,
                      startLongitude: startLng,
                      endPointName: _formData['endPointName']!.trim(),
                      endLatitude: endLat,
                      endLongitude: endLng,
                      stops: stops,
                      timings: timings,
                      frequency: _formData['frequency']!.trim(),
                      assignedDriverId: selectedDriverId,
                      assignedDriverName: selectedDriverName,
                    );

                    if (routeProvider.error != null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(routeProvider.error!),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Route added successfully"),
                            backgroundColor: Color(0xff4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to add route: $e"),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff7B61A1),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Color(0xff7B61A1).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  "Create Route",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
    );
  }

  Widget buildField(String label, String field, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xff7B61A1), size: 20.w),
            hintText: "Enter $label",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            filled: true,
            fillColor: Color(0xffF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Color(0xff4CAF50), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          validator:
              (value) =>
                  value == null || value.trim().isEmpty
                      ? '$label is required'
                      : null,
          onChanged: (value) {
            // Save data immediately when user types
            _formData[field] = value.trim();
          },
          onSaved: (value) {
            // Also save when form is saved
            _formData[field] = value?.trim() ?? '';
          },
          style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
        ),
      ],
    );
  }

  Widget buildCoordinateField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xff7B61A1), size: 20.w),
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            filled: true,
            fillColor: Color(0xffF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Color(0xff4CAF50), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label required';
            }
            if (double.tryParse(value) == null) {
              return 'Invalid $label';
            }
            return null;
          },
          style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
        ),
      ],
    );
  }

  Widget buildDropdownField(
    String label,
    String field,
    IconData icon,
    List<String> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          // Only set value if it exists in options
          value:
              _formData[field] != null && options.contains(_formData[field])
                  ? _formData[field]
                  : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xff7B61A1), size: 20.w),
            hintText: "Select $label",
            filled: true,
            fillColor: Color(0xffF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Color(0xff4CAF50), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          items:
              options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 14.sp)),
                );
              }).toList(),
          validator:
              (value) =>
                  value == null || value.isEmpty ? '$label is required' : null,
          onChanged: (value) {
            // Save data immediately when user selects
            if (value != null) {
              setState(() {
                _formData[field] = value;
              });
            }
          },
          onSaved: (value) {
            // Also save when form is saved
            if (value != null) {
              _formData[field] = value;
            }
          },
        ),
      ],
    );
  }

  void _addStop() {
    showDialog(
      context: context,
      builder:
          (context) => _StopDialog(
            onAdd: (stop) {
              setState(() {
                stops.add(stop);
              });
            },
          ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      stops.removeAt(index);
    });
  }

  void _addTiming() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
      if (time != null) {
        setState(() {
          timings.add(time.format(context));
        });
      }
    });
  }

  void _removeTiming(int index) {
    setState(() {
      timings.removeAt(index);
    });
  }

  bool _validateCoordinates() {
    // Check if controllers are not null and have text
    if (_startLatController.text.trim().isEmpty ||
        _startLngController.text.trim().isEmpty ||
        _endLatController.text.trim().isEmpty ||
        _endLngController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all coordinate fields"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return false;
    }

    // Try to parse coordinates
    try {
      double.parse(_startLatController.text.trim());
      double.parse(_startLngController.text.trim());
      double.parse(_endLatController.text.trim());
      double.parse(_endLngController.text.trim());
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter valid coordinate values"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return false;
    }
  }
}

class _StopDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _StopDialog({required this.onAdd});

  @override
  State<_StopDialog> createState() => _StopDialogState();
}

class _StopDialogState extends State<_StopDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Stop"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Stop Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator:
                  (value) => value?.isEmpty == true ? "Name required" : null,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _latController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Latitude",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty == true) return "Latitude required";
                if (double.tryParse(value!) == null) return "Invalid latitude";
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _lngController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Longitude",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty == true) return "Longitude required";
                if (double.tryParse(value!) == null) return "Invalid longitude";
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd({
                'name': _nameController.text,
                'latitude': double.parse(_latController.text),
                'longitude': double.parse(_lngController.text),
              });
              Navigator.pop(context);
            }
          },
          child: Text("Add Stop"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}
