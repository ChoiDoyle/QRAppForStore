import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrproject/wrapper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ScreenUtilInit(
      builder: () => MaterialApp(
        home: ColorfulSafeArea(color: Colors.cyan, child: Wrapper()),
      ),
      designSize: Size(1170, 2532),
    );
  }
}
