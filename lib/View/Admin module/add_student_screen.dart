import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

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
                      buildField(
                        "Assigned Route",
                        "assignedRoute",
                        Icons.directions_bus_outlined,
                      ),
                      SizedBox(height: 16.h),
                      buildDropdownField(
                        "Payment Status",
                        "paymentStatus",
                        Icons.payment_outlined,
                      ),
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
                                await provider.addStudent(
                                  name: _formData['name']!,
                                  email: _formData['email']!,
                                  password: _formData['password']!,
                                  registrationNumber:
                                      _formData['registrationNumber']!,
                                  mobileNumber: _formData['mobileNumber']!,
                                  address: _formData['address']!,
                                  assignedRoute: _formData['assignedRoute']!,
                                  paymentStatus: _formData['paymentStatus']!,
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
                                        "Student added successfully",
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
                                  Navigator.pop(context);
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

  Widget buildField(
    String label,
    String field,
    IconData icon, {
    bool obscure = false,
    int maxLines = 1,
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
              ['Paid', 'Pending', 'Overdue'].map((String value) {
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
