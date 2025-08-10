import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/driver_attendence_calender_screen.dart';

class SelectDriverForAttendanceScreen extends StatelessWidget {
  const SelectDriverForAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverController = Provider.of<DriverController>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Select Driver")),
      body: StreamBuilder(
        stream: driverController.getAllDrivers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final drivers = snapshot.data!.docs;
          if (drivers.isEmpty) {
            return const Center(child: Text("No drivers found"));
          }
          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final data = drivers[index].data();
              final driverId = drivers[index].id;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['name'] ?? 'Unnamed'),
                subtitle: Text("Employee ID: ${data['employeeId'] ?? 'N/A'}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverAttendanceCalendarScreen(driverId: driverId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
