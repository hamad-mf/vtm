import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/parent_controller.dart';

class AddParentScreen extends StatefulWidget {
  const AddParentScreen({super.key});

  @override
  State<AddParentScreen> createState() => _AddParentScreenState();
}

class _AddParentScreenState extends State<AddParentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  String? _selectedStudentId;
  String? _selectedStudentName;
  String? _selectedStudentRegNo;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParentController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Parent",
          style: TextStyle(fontSize: 19.sp),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              buildField("Parent Name", "parentName", Icons.person_outline),
              SizedBox(height: 16.h),

              // Email
              buildField("Email Address", "parentEmail", Icons.email_outlined),
              SizedBox(height: 16.h),

              // Password
              buildField("Password", "parentPassword", Icons.lock_outline, obscure: true),
              SizedBox(height: 16.h),

              // Mobile
              buildField("Mobile Number", "parentMobileNo", Icons.phone_outlined),
              SizedBox(height: 16.h),

              // Address
              buildField("Address", "parentAddress", Icons.location_on_outlined, maxLines: 3),
              SizedBox(height: 16.h),

              // Student Dropdown
              _buildStudentDropdown(provider),
              SizedBox(height: 30.h),

              // Submit Button
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
                            if (_selectedStudentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please select a Student")),
                              );
                              return;
                            }

                            _formKey.currentState!.save();

                            await provider.addParent(
                              parentName: _formData['parentName']!,
                              parentEmail: _formData['parentEmail']!,
                              parentPassword: _formData['parentPassword']!,
                              studentId: _selectedStudentId!,
                              studentName: _selectedStudentName!,
                              studentRegNo: _selectedStudentRegNo ?? '',
                              parentMobileNo: _formData['parentMobileNo']!,
                              parentAddress: _formData['parentAddress']!,
                            );

                            if (provider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
                              );
                            } else {
                              if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("parent added successfully")),
);
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          "Add Parent",
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
      validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      onSaved: (value) => _formData[field] = value!.trim(),
    );
  }

  Widget _buildStudentDropdown(ParentController provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getAllStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
        if (snapshot.hasError) return Text("Error loading students");

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Text("No students found");

        return DropdownButtonFormField<String>(
          value: _selectedStudentId,
          decoration: InputDecoration(
            labelText: "Select Student",
            prefixIcon: Icon(Icons.school, color: Color(0xff7B61A1)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            filled: true,
            fillColor: Color(0xffF8F9FA),
          ),
          items: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text("${data['name']} (${data['registrationNumber']})"),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStudentId = value;
              final data = docs.firstWhere((doc) => doc.id == value).data() as Map<String, dynamic>;
              _selectedStudentName = data['name'];
              _selectedStudentRegNo = data['registrationNumber'];
            });
          },
          validator: (value) => value == null ? "Please select a student" : null,
        );
      },
    );
  }
}
