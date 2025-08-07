import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';

class EditStudentSheet extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;

  const EditStudentSheet({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  State<EditStudentSheet> createState() => _EditStudentSheetState();
}

class _EditStudentSheetState extends State<EditStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, String> _formData;

  @override
  void initState() {
    super.initState();
    _formData = {
      'name': widget.studentData['name'],
      'registrationNumber': widget.studentData['registrationNumber'],
      'mobileNumber': widget.studentData['mobileNumber'],
      'address': widget.studentData['address'],
      'assignedRoute': widget.studentData['assignedRoute'],
      'paymentStatus': widget.studentData['paymentStatus'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Edit Student",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._formData.keys.map((field) => buildField(field)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await context.read<StudentController>().updateStudent(
                      widget.studentId,
                      _formData,
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF00c9a7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String field) {
    if (field == 'paymentStatus') {
      return DropdownButtonFormField<String>(
        value: _formData[field],
        decoration: const InputDecoration(labelText: 'Payment Status'),
        items:
            ['Paid', 'Pending', 'Overdue'].map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
            }).toList(),
        onChanged: (value) {
          setState(() {
            _formData[field] = value!;
          });
        },
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      );
    }

    return TextFormField(
      initialValue: _formData[field],
      decoration: InputDecoration(labelText: (field)),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      onSaved: (value) => _formData[field] = value!,
    );
  }
}
