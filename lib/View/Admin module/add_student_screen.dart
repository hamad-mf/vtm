import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};
  String? _selectedRouteId;
  String? _selectedRouteName;
  String? _selectedDriverId;
  String? _selectedDriverName;

  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  DateTime? _feeExpiryDate;

  // Google Maps related variables
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    17.385044,
    78.486671,
  ); // Default to Hyderabad
  Set<Marker> _markers = {};
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle permanently denied permission
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _updateLocationFields();
          _updateMarker();
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_selectedLocation),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Update marker on map
  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('destination'),
          position: _selectedLocation,
          infoWindow: const InfoWindow(
            title: 'Student Destination',
            snippet: 'Tap to change location',
          ),
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _selectedLocation = newPosition;
              _updateLocationFields();
            });
          },
        ),
      };
    });
  }

  // Update text fields with selected coordinates
  void _updateLocationFields() {
    _latController.text = _selectedLocation.latitude.toStringAsFixed(6);
    _lngController.text = _selectedLocation.longitude.toStringAsFixed(6);
  }

  // Handle map tap
  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _updateLocationFields();
      _updateMarker();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Student", style: TextStyle(fontSize: 19.sp)),
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
                Container(
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
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "New Student Registration",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Fill in the details below",
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

                // Form Fields Card
                Container(
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
                    children: [
                      buildField("Full Name", "name", Icons.person_outline),
                      SizedBox(height: 16.h),
                      buildField(
                        "Email Address",
                        "email",
                        Icons.email_outlined,
                      ),
                      SizedBox(height: 16.h),
                      buildField(
                        "Password",
                        "password",
                        Icons.lock_outline,
                        obscure: true,
                      ),
                      SizedBox(height: 16.h),
                      buildField(
                        "Registration Number",
                        "registrationNumber",
                        Icons.badge_outlined,
                      ),
                      SizedBox(height: 16.h),
                      buildField(
                        "Mobile Number",
                        "mobileNumber",
                        Icons.phone_outlined,
                      ),
                      SizedBox(height: 16.h),
                      buildField(
                        "Address",
                        "address",
                        Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),
                      // ROUTE SELECTION FROM FIRESTORE
                      _buildRouteDropdown(),
                      SizedBox(height: 16.h),
                      // DRIVER SELECTION FROM FIRESTORE
                      _buildDriversDropdown(),
                      SizedBox(height: 16.h),

                      // MAP SECTION FOR DESTINATION SELECTION
                      _buildDestinationMapSection(),

                      SizedBox(height: 16.h),
                      buildDropdownField(
                        "Payment Status",
                        "paymentStatus",
                        Icons.payment_outlined,
                      ),
                      SizedBox(height: 16.h),
                      _buildDateField("Fee Expiry Date", Icons.calendar_today, (
                        date,
                      ) {
                        _feeExpiryDate = date;
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56.h,
                  child:
                      provider.isLoading
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
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _formData['assignedRouteId'] =
                                    _selectedRouteId ?? "";
                                _formData['assignedRouteName'] =
                                    _selectedRouteName ?? "";
                                _formData['assignedRoute'] =
                                    _selectedRouteName ?? "";
                                _formData['destinationLatitude'] =
                                    _latController.text.trim();
                                _formData['destinationLongitude'] =
                                    _lngController.text.trim();
                                _formData['assignedDriverId'] =
                                    _selectedDriverId ?? "";
                                _formData['assignedDriverName'] =
                                    _selectedDriverName ?? "";

                                await provider.addStudent(
                                  feeExpiryDate: _feeExpiryDate!,
                                  assignedDriverId:
                                      _formData['assignedDriverId']!,
                                  assignedDriverName:
                                      _formData['assignedDriverName']!,
                                  context: context,
                                  name: _formData['name']!,
                                  email: _formData['email']!,
                                  password: _formData['password']!,
                                  registrationNumber:
                                      _formData['registrationNumber']!,
                                  mobileNumber: _formData['mobileNumber']!,
                                  address: _formData['address']!,
                                  assignedRouteId:
                                      _formData['assignedRouteId']!,
                                  assignedRouteName:
                                      _formData['assignedRouteName']!,
                                  paymentStatus: _formData['paymentStatus']!,
                                  destinationLatitude:
                                      _formData['destinationLatitude']!,
                                  destinationLongitude:
                                      _formData['destinationLongitude']!,
                                );
                                _formKey.currentState!.reset();
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
                              "Add Student",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Destination Map Selection Section
  Widget _buildDestinationMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Destination Location",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xff333333),
              ),
            ),
            Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isMapExpanded = !_isMapExpanded;
                });
              },
              icon: Icon(
                _isMapExpanded ? Icons.expand_less : Icons.expand_more,
                color: Color(0xff7B61A1),
              ),
              label: Text(
                _isMapExpanded ? "Hide Map" : "Show Map",
                style: TextStyle(color: Color(0xff7B61A1)),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Coordinate Input Fields
        Row(
          children: [
            Expanded(
              child: buildLatLngField(
                "Latitude",
                _latController,
                "destinationLatitude",
                onChanged: (value) {
                  final lat = double.tryParse(value);
                  if (lat != null && lat >= -90 && lat <= 90) {
                    final lng = double.tryParse(_lngController.text);
                    if (lng != null && lng >= -180 && lng <= 180) {
                      setState(() {
                        _selectedLocation = LatLng(lat, lng);
                        _updateMarker();
                      });
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(_selectedLocation),
                        );
                      }
                    }
                  }
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: buildLatLngField(
                "Longitude",
                _lngController,
                "destinationLongitude",
                onChanged: (value) {
                  final lng = double.tryParse(value);
                  if (lng != null && lng >= -180 && lng <= 180) {
                    final lat = double.tryParse(_latController.text);
                    if (lat != null && lat >= -90 && lat <= 90) {
                      setState(() {
                        _selectedLocation = LatLng(lat, lng);
                        _updateMarker();
                      });
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(_selectedLocation),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),

        if (_isMapExpanded) ...[
          SizedBox(height: 16.h),
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  // Consume scroll notifications to prevent parent ListView interference
                  return true;
                },
                child: GestureDetector(
                  // Prevent parent gestures from interfering
                  onPanDown: (_) {},
                  onPanUpdate: (_) {},
                  onPanEnd: (_) {},

                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: 15.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      _updateMarker();
                    },
                    onTap: (LatLng position) {
                      setState(() {
                        _selectedLocation = position;
                        _updateLocationFields();
                        _updateMarker();
                      });
                    },

                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    // Proper gesture recognizers for map interaction
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16.w, color: Colors.grey),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Tap on the map to select destination or drag the pin marker",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: Icon(Icons.my_location, size: 16.w),
                  label: Text("Use Current Location"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff7B61A1).withOpacity(0.1),
                    foregroundColor: Color(0xff7B61A1),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDateField(
    String label,
    IconData icon,
    Function(DateTime) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365 * 10)),
        );
        if (picked != null) setState(() => onPicked(picked));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Color(0xffF8F9FA),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xff7B61A1)),
            SizedBox(width: 16.w),
            Text(label, style: TextStyle(color: Colors.grey.shade400)),
            Spacer(),
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  // drivers Dropdown - Gets Data From Firestore
  Widget _buildDriversDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assigned Driver",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('drivers')
                  .orderBy('name')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            if (snapshot.hasError)
              return Text(
                "Failed to load drivers",
                style: TextStyle(color: Colors.red),
              );
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty)
              return Text(
                "No drivers found",
                style: TextStyle(color: Colors.grey),
              );

            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedDriverId,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.directions_bus_outlined,
                  color: Color(0xff7B61A1),
                ),
                hintText: "Select Assigned Driver",
                filled: true,
                fillColor: Color(0xffF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              items:
                  docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final routeName = data['name'] ?? doc.id;
                    final driverId = data['driverId'] ?? doc.id;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        routeName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xff333333),
                        ),
                      ),
                    );
                  }).toList(),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Assigned driver is required'
                          : null,
              onChanged: (id) {
                setState(() {
                  _selectedDriverId = id!;
                  // Also capture the display name for later saving to the student document
                  final doc = docs.firstWhere((doc) => doc.id == id);
                  final data = doc.data() as Map<String, dynamic>;
                  _selectedDriverName = data['name'] ?? id;
                });
              },
            );
          },
        ),
      ],
    );
  }

  // Route Dropdown - Gets Data From Firestore
  Widget _buildRouteDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assigned Route",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('routes')
                  .orderBy('routeName')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            if (snapshot.hasError)
              return Text(
                "Failed to load routes",
                style: TextStyle(color: Colors.red),
              );
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty)
              return Text(
                "No routes found",
                style: TextStyle(color: Colors.grey),
              );

            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedRouteId,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.directions_bus_outlined,
                  color: Color(0xff7B61A1),
                ),
                hintText: "Select Assigned Route",
                filled: true,
                fillColor: Color(0xffF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              items:
                  docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final routeName = data['routeName'] ?? doc.id;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        routeName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xff333333),
                        ),
                      ),
                    );
                  }).toList(),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Assigned Route is required'
                          : null,
              onChanged: (id) {
                setState(() {
                  _selectedRouteId = id;
                  final doc = docs.firstWhere((doc) => doc.id == id);
                  final data = doc.data() as Map<String, dynamic>;
                  _selectedRouteName = data['routeName'] ?? id;
                });
              },
            );
          },
        ),
      ],
    );
  }

  // destination latitude & longitude fields
  Widget buildLatLngField(
    String label,
    TextEditingController controller,
    String key, {
    Function(String)? onChanged,
  }) {
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
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Color(0xff7B61A1),
            ),
            hintText: label,
            filled: true,
            fillColor: Color(0xffF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty)
              return '$label is required';
            final parsed = double.tryParse(value.trim());
            if (parsed == null) return 'Enter valid $label';
            if (label.contains('Latitude') && (parsed < -90 || parsed > 90))
              return 'Latitude must be between -90 and 90';
            if (label.contains('Longitude') && (parsed < -180 || parsed > 180))
              return 'Longitude must be between -180 and 180';
            return null;
          },
          onChanged: onChanged,
        ),
      ],
    );
  }

  // other fields, unchanged
  Widget buildField(
    String label,
    String field,
    IconData icon, {
    bool obscure = false,
    int maxLines = 1,
  }) {
    bool isNumericField =
        field == "registrationNumber" || field == "mobileNumber" || field == "";
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
          keyboardType:
              isNumericField ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
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
          obscureText: obscure,
          validator:
              (value) =>
                  value == null || value.isEmpty ? '$label is required' : null,
          onSaved: (value) => _formData[field] = value!,
          style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
        ),
      ],
    );
  }

  Widget buildDropdownField(String label, String field, IconData icon) {
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
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xff7B61A1), size: 20.w),
            hintText: "Select $label",
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
          items:
              ['Paid', 'Pending', 'Overdue', 'Grace'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
                  ),
                );
              }).toList(),
          validator:
              (value) =>
                  value == null || value.isEmpty ? '$label is required' : null,
          onChanged: (value) => _formData[field] = value!,
          style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
        ),
      ],
    );
  }
}
