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

                            await provider.addStaff(
                              name: _formData['name']!,
                              email: _formData['email']!,
                              password: _formData['password']!,
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

  Widget buildField(String label, String field, IconData icon,
      {bool obscure = false, int maxLines = 1}) {
    return TextFormField(
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xff7B61A1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Color(0xffF8F9FA),
      ),
      validator: (value) => value == null || value.isEmpty
          ? "$label is required"
          : null,
      onSaved: (value) => _formData[field] = value!.trim(),
    );
  }
}
