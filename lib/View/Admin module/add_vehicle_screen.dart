import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/vehicle_controller.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  DateTime? _registrationExpiry;
  DateTime? _insuranceExpiry;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Vehicle", style: TextStyle(fontSize: 19.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionCard("Vehicle Details", Icons.directions_bus, [
                buildField("Bus ID", "busId", Icons.confirmation_number),
                SizedBox(height: 16.h),
                buildField("Vehicle Number", "vehicleNumber", Icons.numbers),
                SizedBox(height: 16.h),
                buildDropdownField(
                  "Type", "type", Icons.category_outlined,
                  ['Mini Bus', 'College Bus', 'Van'],
                ),
                SizedBox(height: 16.h),
                buildField("Capacity", "capacity", Icons.people, isNumber: true),
              ]),

              SizedBox(height: 20.h),

              _buildSectionCard("Documentation", Icons.description, [
                _buildDateField("Registration Expiry Date", Icons.calendar_today, (date) {
                  _registrationExpiry = date;
                }),
                SizedBox(height: 16.h),
                _buildDateField("Insurance Expiry Date", Icons.calendar_today, (date) {
                  _insuranceExpiry = date;
                }),
              ]),

              SizedBox(height: 30.h),

              provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _registrationExpiry != null &&
                          _insuranceExpiry != null) {
                        _formKey.currentState!.save();

                        await provider.addVehicle(
                          busId: _formData['busId'],
                          vehicleNumber: _formData['vehicleNumber'],
                          type: _formData['type'],
                          capacity: int.parse(_formData['capacity']),
                          registrationExpiry: _registrationExpiry!,
                          insuranceExpiry: _insuranceExpiry!,
                        );

                        if (provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Vehicle added successfully"), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text("Add Vehicle"),
                  ),
            ],
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
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(icon, color: Color(0xff7B61A1), size: 20.w),
            SizedBox(width: 8.w),
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xff7B61A1))),
          ],
        ),
        SizedBox(height: 16.h),
        ...children,
      ]),
    );
  }

  Widget buildField(String label, String field, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xff7B61A1)),
        hintText: "Enter $label",
        filled: true,
        fillColor: Color(0xffF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      onSaved: (value) => _formData[field] = value!,
    );
  }

  Widget buildDropdownField(String label, String field, IconData icon, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xff7B61A1)),
        filled: true,
        fillColor: Color(0xffF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
      items: options.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      onChanged: (value) => _formData[field] = value!,
    );
  }

  Widget _buildDateField(String label, IconData icon, Function(DateTime) onPicked) {
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
}
