import 'package:cloud_firestore/cloud_firestore.dart';
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
  DateTime? _feeExpiryDate;

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
    final Timestamp? timestamp = widget.studentData['feeExpiryDate'];
    if (timestamp != null) {
      _feeExpiryDate = timestamp.toDate();
    }
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

              // Build fields for editable student info
              ..._formData.keys.map((field) => buildField(field)).toList(),

              const SizedBox(height: 16),

              // Date picker for feeExpiryDate
              InkWell(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _feeExpiryDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _feeExpiryDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fee Expiry Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    _feeExpiryDate != null
                        ? '${_feeExpiryDate!.day}/${_feeExpiryDate!.month}/${_feeExpiryDate!.year}'
                        : 'Select a date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  if (_feeExpiryDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a fee expiry date'),
                      ),
                    );
                    return;
                  }

                  _formKey.currentState!.save();

                  // Prepare update data with feeExpiryDate as Timestamp
                  Map<String, dynamic> updateData = _formData.map(
                    (key, value) => MapEntry(key, value),
                  );
                  updateData['feeExpiryDate'] = Timestamp.fromDate(
                    _feeExpiryDate!,
                  );

                  await context.read<StudentController>().updateStudent(
                    widget.studentId,
                    updateData,
                  );

                  Navigator.pop(context); // Close bottom sheet or dialog
                  Navigator.pop(context); // Optional additional pop if needed
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
      decoration: InputDecoration(labelText: field),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      onSaved: (value) => _formData[field] = value!,
    );
  }
}
