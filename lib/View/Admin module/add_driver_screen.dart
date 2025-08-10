import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/vehicle_controller.dart';

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  DateTime? _licenseExpiry;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Driver", style: TextStyle(fontSize: 19.sp)),
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
                            "New Driver Registration",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Fill in the driver details below",
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

                // Basic Information Card
                _buildSectionCard("Basic Information", Icons.person, [
                  buildField("Driver Name", "name", Icons.person_outline),
                  SizedBox(height: 16.h),
                  buildField("Email Address", "email", Icons.email_outlined),
                  SizedBox(height: 16.h),
                  buildField(
                    "Password",
                    "password",
                    Icons.lock_outline,
                    obscure: true,
                  ),
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
                    "6 digit pin for attendence marking",
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text(
                              "No available vehicles found",
                              style: TextStyle(color: Colors.grey.shade600),
                            );
                          }

                          final vehicles = snapshot.data!.docs;

                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.directions_bus_outlined,
                                color: Color(0xff7B61A1),
                              ),
                              hintText: "Select Available Vehicle",
                              filled: true,
                              fillColor: Color(0xffF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items:
                                vehicles.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return DropdownMenuItem<String>(
                                    value: data['busId'],
                                    child: Text(
                                      "${data['busId']} - ${data['vehicleNumber']} (${data['type']})",
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  );
                                }).toList(),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? "Vehicle is required"
                                        : null,
                            onChanged: (value) {
                              _formData['assignedBusId'] = value!;
                            },
                          );
                        },
                      );
                    },
                  ),
                ]),

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
                              if (_formKey.currentState!.validate() &&
                                  _licenseExpiry != null) {
                                _formKey.currentState!.save();

                                await provider.addDriver(
                                  pincode: _formData['pinNumber']!,
                                  name: _formData['name']!,
                                  email: _formData['email']!,
                                  password: _formData['password']!,
                                  employeeId: _formData['employeeId']!,
                                  contactNumber: _formData['contactNumber']!,
                                  licenseNumber: _formData['licenseNumber']!,
                                  licenseType: _formData['licenseType']!,
                                  licenseExpiry: _licenseExpiry!,
                                  assignedBusId: _formData['assignedBusId']!,
                                );

                                if (provider.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(provider.error!),
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Driver added successfully",
                                      ),
                                      backgroundColor: Color(0xff4CAF50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                  );
                                  _formKey.currentState!.reset();
                                  _licenseExpiry = null;
                                  Navigator.pop(context);
                                }
                              } else if (_licenseExpiry == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please select license expiry date",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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
                              "Add Driver",
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
            return null;
          },
          onSaved: (value) {
            // Save all fields as strings, including pincode
            _formData[field] = value!;
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
              options.map((String value) {
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
              initialDate: DateTime.now().add(Duration(days: 365)),
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
                    color:
                        _licenseExpiry == null
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
