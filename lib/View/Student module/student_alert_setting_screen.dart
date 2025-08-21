import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/alert_controller.dart';

class StudentAlertSettingsScreen extends StatefulWidget {
  const StudentAlertSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StudentAlertSettingsScreen> createState() =>
      _StudentAlertSettingsScreenState();
}

class _StudentAlertSettingsScreenState
    extends State<StudentAlertSettingsScreen> {
  bool isEnabled = true;
  int alertDistance = 500; // meters
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final alertController = Provider.of<AlertController>(
      context,
      listen: false,
    );
    await alertController.loadAlertSettings();

    setState(() {
      alertDistance = alertController.alertDistance;
      isEnabled = alertController.isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alert Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable/Disable Switch
            SwitchListTile(
              title: Text('Enable Destination Alert'),
              subtitle: Text(
                'Get notified when bus approaches your destination',
              ),
              value: isEnabled,
              onChanged: (value) => setState(() => isEnabled = value),
            ),

            SizedBox(height: 24),

            // Alert Distance Selection
            Text(
              'Alert Distance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get notified when bus is within this distance from your destination',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: alertDistance.clamp(10, 300).toDouble(),
                            min: 10,
                            max: 300,
                            divisions: 10,
                            label: '${alertDistance}m',
                            onChanged:
                                (value) => setState(
                                  () => alertDistance = value.round(),
                                ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          '${alertDistance}m',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          setState(() => isLoading = true);
                          try {
                            final alertController =
                                Provider.of<AlertController>(
                                  context,
                                  listen: false,
                                );

                            await alertController.saveAlertSettings(
                              distance: alertDistance,
                              enabled: isEnabled,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Alert settings saved successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving settings: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save Settings'),
              ),
            ),

            // ElevatedButton(
            //   onPressed: () {
            //     Provider.of<AlertController>(
            //       context,
            //       listen: false,
            //     ).testBusAlert();
            //   },
            //   child: Text('Test Bus Alert Sound'),
            // ),
          ],
        ),
      ),
    );
  }
}
