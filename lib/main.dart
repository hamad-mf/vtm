import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/driver_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/route_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/vehicle_controller.dart';
import 'package:vignan_transportation_management/Controllers/Common%20Controllers/login_controller.dart';
import 'package:vignan_transportation_management/Controllers/Admin%20Controllers/student_controller.dart';

import 'package:vignan_transportation_management/View/Common%20Screens/splash_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
