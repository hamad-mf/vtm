import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/vehicle_controller.dart';

class EditDriverScreen extends StatefulWidget {
  final String driverId;
  final Map<String, dynamic> driverData;

  const EditDriverScreen({
    super.key,
    required this.driverId,
    required this.driverData,
  });

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  DateTime? _licenseExpiry;
  String? _selectedBusId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    // Initialize form data with existing driver data
    _formData['name'] = widget.driverData['name'] ?? '';
    _formData['email'] = widget.driverData['email'] ?? '';
    _formData['employeeId'] = widget.driverData['employeeId'] ?? '';
    _formData['contactNumber'] = widget.driverData['contactNumber'] ?? '';
    _formData['pinNumber'] = widget.driverData['pincode'] ?? '';
    _formData['licenseNumber'] = widget.driverData['licenseNumber'] ?? '';
    _formData['licenseType'] = widget.driverData['licenseType'] ?? '';
    
    // Initialize bus assignment
    _selectedBusId = widget.driverData['assignedBusId'];

    // Initialize license expiry date
    final Timestamp? timestamp = widget.driverData['licenseExpiry'];
    if (timestamp != null) {
      _licenseExpiry = timestamp.toDate();
    }
  }

  Future<void> _updateDriver() async {
    if (!_formKey.currentState!.validate() || _licenseExpiry == null) {
      if (_licenseExpiry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select license expiry date"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _formKey.currentState!.save();

      // Check for pincode uniqueness (excluding current driver)
      if (_formData['pinNumber'] != widget.driverData['pincode']) {
        var query = await FirebaseFirestore.instance
            .collection('drivers')
            .where('pincode', isEqualTo: _formData['pinNumber'])
            .get();
        
        bool pincodeExists = query.docs.any((doc) => doc.id != widget.driverId);
        if (pincodeExists) {
          throw Exception('Pincode already exists. Please choose a unique PIN.');
        }
      }

      // Handle bus reassignment if changed
      String? oldBusId = widget.driverData['assignedBusId'];
      if (oldBusId != _selectedBusId) {
        // Remove assignment from old bus
        if (oldBusId != null) {
          await FirebaseFirestore.instance
              .collection('vehicles')
              .doc(oldBusId)
              .update({
            'assignedDriverId': null,
            'assignedRouteId': null,
          });
        }

        // Assign new bus
        if (_selectedBusId != null) {
          DocumentSnapshot busDoc = await FirebaseFirestore.instance
              .collection('vehicles')
              .doc(_selectedBusId!)
              .get();
          
          if (!busDoc.exists) {
            throw Exception("Selected bus not found");
          }
          
          if (busDoc['assignedDriverId'] != null && busDoc['assignedDriverId'] != widget.driverId) {
            throw Exception("This bus is already assigned to another driver");
          }

          await FirebaseFirestore.instance
              .collection('vehicles')
              .doc(_selectedBusId!)
              .update({
            'assignedDriverId': widget.driverId,
            'assignedRouteId': null,
          });
        }
      }

      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': _formData['name']!.trim(),
        'email': _formData['email']!.trim().toLowerCase(),
        'employeeId': _formData['employeeId']!.trim(),
        'contactNumber': _formData['contactNumber']!.trim(),
        'pincode': _formData['pinNumber']!.trim(),
        'licenseNumber': _formData['licenseNumber']!.trim(),
        'licenseType': _formData['licenseType']!,
        'licenseExpiry': Timestamp.fromDate(_licenseExpiry!),
        'assignedBusId': _selectedBusId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await context.read<DriverController>().updateDriver(
        widget.driverId,
        updateData,
      );

      // Also update roles collection name if changed
      if (_formData['name'] != widget.driverData['name']) {
        await FirebaseFirestore.instance
            .collection('roles')
            .doc(widget.driverId)
            .update({'name': _formData['name']!.trim()});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Driver updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating driver: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Driver", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _updateDriver,
            icon: Icon(Icons.save, color: Color(0xff7B61A1)),
            label: Text(
              "Save",
              style: TextStyle(
                color: Color(0xff7B61A1),
                fontWeight: FontWeight.w600,
              ),
            ),
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
                          Icons.person_outline,
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
                              "Edit Driver Details",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Modify driver information",
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

                // Basic Information Card
                _buildSectionCard("Basic Information", Icons.person, [
                  buildField("Driver Name", "name", Icons.person_outline),
                  SizedBox(height: 16.h),
                  buildField("Email Address", "email", Icons.email_outlined),
                  SizedBox(height: 16.h),
                  buildField("Employee ID", "employeeId", Icons.badge_outlined),
                  SizedBox(height: 16.h),
                  buildField(
                    "Contact Number",
                    "contactNumber",
                    Icons.phone_outlined,
                  ),
                  SizedBox(height: 16.h),
                  buildField(
                    "6 digit pin for attendance marking",
                    "pinNumber",
                    Icons.security_outlined,
                  ),
                ]),

                SizedBox(height: 20.h),

                // License Information Card
                _buildSectionCard(
                  "License Information",
                  Icons.card_membership,
                  [
                    buildField(
                      "License Number",
                      "licenseNumber",
                      Icons.credit_card_outlined,
                    ),
                    SizedBox(height: 16.h),
                    buildDropdownField(
                      "License Type",
                      "licenseType",
                      Icons.category_outlined,
                      ['LMV', 'HMV', 'MCWG', 'MCWOG'],
                    ),
                    SizedBox(height: 16.h),
                    _buildDateField(
                      "License Expiry Date",
                      Icons.calendar_today_outlined,
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Bus Assignment Card
                _buildSectionCard("Bus Assignment", Icons.directions_bus, [
                  Consumer<VehicleController>(
                    builder: (context, vehicleProvider, child) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: vehicleProvider.getAvailableVehicles(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff7B61A1),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(
                              "Error loading vehicles",
                              style: TextStyle(color: Colors.red),
                            );
                          }

                          List<QueryDocumentSnapshot> vehicles = [];
                          if (snapshot.hasData) {
                            vehicles = snapshot.data!.docs;
                          }

                          // Add current assigned bus if it exists and isn't in available list
                          String? currentBusId = widget.driverData['assignedBusId'];
                          if (currentBusId != null) {
                            bool isCurrentBusInList = vehicles.any((doc) => 
                                (doc.data() as Map<String, dynamic>)['busId'] == currentBusId);
                            
                            if (!isCurrentBusInList) {
                              // Fetch current bus details if not in available list
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('vehicles')
                                    .doc(currentBusId)
                                    .get(),
                                builder: (context, currentBusSnapshot) {
                                  if (currentBusSnapshot.hasData && 
                                      currentBusSnapshot.data!.exists) {
                                    vehicles.insert(0, currentBusSnapshot.data! as QueryDocumentSnapshot);
                                  }
                                  return _buildVehicleDropdown(vehicles);
                                },
                              );
                            }
                          }

                          return _buildVehicleDropdown(vehicles);
                        },
                      );
                    },
                  ),
                ]),

                SizedBox(height: 30.h),

                // Update Button
                Container(
                  width: double.infinity,
                  height: 56.h,
                  child: _isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Color(0xff7B61A1).withOpacity(0.7),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _updateDriver,
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
                            "Update Driver",
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

  Widget _buildVehicleDropdown(List<QueryDocumentSnapshot> vehicles) {
    if (vehicles.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          "No vehicles available for assignment",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedBusId,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.directions_bus_outlined,
          color: Color(0xff7B61A1),
        ),
        hintText: "Select Vehicle",
        filled: true,
        fillColor: Color(0xffF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
      items: vehicles.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final busId = data['busId'] ?? doc.id;
        final vehicleNumber = data['vehicleNumber'] ?? 'Unknown';
        final type = data['type'] ?? 'Unknown';
        
        return DropdownMenuItem<String>(
          value: busId,
          child: Text(
            "$busId - $vehicleNumber ($type)",
            style: TextStyle(fontSize: 14.sp),
          ),
        );
      }).toList(),
      validator: (value) => value == null || value.isEmpty
          ? "Vehicle is required"
          : null,
      onChanged: (value) {
        setState(() {
          _selectedBusId = value;
        });
      },
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

  Widget buildField(
    String label,
    String field,
    IconData icon, {
    bool obscure = false,
    int maxLines = 1,
  }) {
    bool isNumericField = field == "pinNumber" || field == "contactNumber";
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
          initialValue: _formData[field],
          keyboardType: isNumericField ? TextInputType.number : TextInputType.text,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            if (field == "contactNumber") {
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'Enter a valid 10-digit phone number';
              }
            }
            if (field == "pinNumber") {
              if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                return 'Enter a valid 6-digit PIN';
              }
            }
            if (field == "email") {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
          onSaved: (value) {
            _formData[field] = value!.trim();
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
          value: _formData[field],
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
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
              ),
            );
          }).toList(),
          validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
          onChanged: (value) => setState(() => _formData[field] = value!),
          style: TextStyle(fontSize: 14.sp, color: Color(0xff333333)),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, IconData icon) {
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
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _licenseExpiry ?? DateTime.now().add(Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365 * 10)),
            );
            if (picked != null) {
              setState(() {
                _licenseExpiry = picked;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Color(0xffF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(icon, color: Color(0xff7B61A1), size: 20.w),
                SizedBox(width: 16.w),
                Text(
                  _licenseExpiry == null
                      ? "Select $label"
                      : "${_licenseExpiry!.day}/${_licenseExpiry!.month}/${_licenseExpiry!.year}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _licenseExpiry == null
                        ? Colors.grey.shade400
                        : Color(0xff333333),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade400,
                  size: 16.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}