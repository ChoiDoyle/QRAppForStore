import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:qrproject/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hearder.dart';
import 'input_wrapper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  void initState() {
    validateStoreName(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.cyan.shade500,
            Colors.cyan.shade300,
            Colors.cyan.shade400
          ])),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 80.h,
              ),
              const Header(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      )),
                  child: InputWrapper(),
                ),
              )
            ],
          )),
    );
  }

  Future validateStoreName(context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var storeName = sharedPreferences.getString('storeName');
    if (storeName == null) {
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Home(storeID: storeName),
          ));
    }
  }
}
