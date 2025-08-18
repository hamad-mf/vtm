import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/alert_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/attendence_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/parent_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/route_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/staff_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/vehicle_controller.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';
import 'package:vignan_transportation_management/View/Admin%20module/notification_service.dart';

import 'package:vignan_transportation_management/View/Common%20Screens/splash_screen.dart';
import 'package:vignan_transportation_management/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();

  final notificationService = NotificationService();
  await notificationService.initialize();
  notificationService.registerHandlers();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => StudentController()),
        ChangeNotifierProvider(create: (context) => DriverController()),
        ChangeNotifierProvider(create: (context) => RouteController()),
        ChangeNotifierProvider(create: (context) => AttendanceController()),
        ChangeNotifierProvider(create: (context) => ParentController()),
        ChangeNotifierProvider(create: (context) => StaffController()),
        ChangeNotifierProvider(create: (context) => AlertController()),
        ChangeNotifierProvider(create: (_) => VehicleController()),
      ],
      child: ScreenUtilInit(
        designSize: Size(393, 852),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
