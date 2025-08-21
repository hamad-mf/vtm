import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/staff_controller.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  String? _selectedRouteId;
  String? _selectedRouteName;

  String? _selectedDriverId;
  String? _selectedDriverName;

  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Staff", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField("Name", "name", Icons.person_outline),
              SizedBox(height: 16.h),
              buildField("Email Address", "email", Icons.email_outlined),
              SizedBox(height: 16.h),
              buildField("Password", "password", Icons.lock_outline, obscure: true),
              SizedBox(height: 24.h),

              // Route Dropdown
              _buildRouteDropdown(),
              SizedBox(height: 16.h),

              // Driver Dropdown
              _buildDriversDropdown(),
              SizedBox(height: 16.h),

              // Destination Lat/Lng Fields
              buildLatLngField("Destination Latitude", _latController, "destinationLatitude"),
              SizedBox(height: 16.h),
              buildLatLngField("Destination Longitude", _lngController, "destinationLongitude"),
              SizedBox(height: 30.h),

              SizedBox(
                height: 56.h,
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff7B61A1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _formData['assignedRouteId'] = _selectedRouteId ?? "";
                            _formData['assignedRouteName'] = _selectedRouteName ?? "";
                            _formData['assignedDriverId'] = _selectedDriverId ?? "";
                            _formData['assignedDriverName'] = _selectedDriverName ?? "";

                            _formData['destinationLatitude'] = _latController.text.trim();
                            _formData['destinationLongitude'] = _lngController.text.trim();

                            await provider.addStaff(
                              name: _formData['name']!,
                              email: _formData['email']!,
                              password: _formData['password']!,
                              assignedDriverId: _formData['assignedDriverId']!,
                              assignedDriverName: _formData['assignedDriverName']!,
                              assignedRouteId: _formData['assignedRouteId']!,
                              assignedRouteName: _formData['assignedRouteName']!,
                              destinationLatitude: _formData['destinationLatitude']!,
                              destinationLongitude: _formData['destinationLongitude']!,
                            );

                            if (provider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Staff added successfully"), backgroundColor: Colors.green),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          "Add Staff",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, String field, IconData icon, {bool obscure = false, int maxLines = 1}) {
    bool isNumericField = field == "mobileNumber" || field == "destinationLatitude" || field == "destinationLongitude";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xff333333))),
        SizedBox(height: 8.h),
        TextFormField(
          keyboardType: isNumericField ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xff7B61A1), size: 20.w),
            hintText: "Enter $label",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            filled: true,
            fillColor: Color(0xffF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Color(0xff4CAF50), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.red.shade300, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.red, width: 2)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
          onSaved: (value) => _formData[field] = value!,
          style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
        ),
      ],
    );
  }

  Widget _buildDriversDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assigned Driver", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xff333333))),
        SizedBox(height: 8.h),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('drivers').orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
            if (snapshot.hasError) return Text("Failed to load drivers", style: TextStyle(color: Colors.red));
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return Text("No drivers found", style: TextStyle(color: Colors.grey));

            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedDriverId,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.directions_bus_outlined, color: Color(0xff7B61A1)),
                hintText: "Select Assigned Driver",
                filled: true,
                fillColor: Color(0xffF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
              items: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final driverName = data['name'] ?? doc.id;
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(driverName, style: TextStyle(fontSize: 14.sp, color: Color(0xff333333))),
                );
              }).toList(),
              validator: (value) => value == null || value.isEmpty ? 'Assigned driver is required' : null,
              onChanged: (id) {
                setState(() {
                  _selectedDriverId = id!;
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

  Widget _buildRouteDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assigned Route", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xff333333))),
        SizedBox(height: 8.h),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('routes').orderBy('routeName').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
            if (snapshot.hasError) return Text("Failed to load routes", style: TextStyle(color: Colors.red));
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return Text("No routes found", style: TextStyle(color: Colors.grey));

            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedRouteId,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.directions_bus_outlined, color: Color(0xff7B61A1)),
                hintText: "Select Assigned Route",
                filled: true,
                fillColor: Color(0xffF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
              items: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final routeName = data['routeName'] ?? doc.id;
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(routeName, style: TextStyle(fontSize: 14.sp, color: Color(0xff333333))),
                );
              }).toList(),
              validator: (value) => value == null || value.isEmpty ? 'Assigned Route is required' : null,
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

  Widget buildLatLngField(
    String label,
    TextEditingController controller,
    String key,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xff333333))),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xff7B61A1)),
            hintText: label,
            filled: true,
            fillColor: Color(0xffF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return '$label is required';
            final parsed = double.tryParse(value.trim());
            if (parsed == null) return 'Enter valid $label';
            if (label.contains('Latitude') && (parsed < -90 || parsed > 90)) return 'Latitude must be between -90 and 90';
            if (label.contains('Longitude') && (parsed < -180 || parsed > 180)) return 'Longitude must be between -180 and 180';
            return null;
          },
        ),
      ],
    );
  }
}
