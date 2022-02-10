import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrproject/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputWrapper extends StatelessWidget {
  TextEditingController idInputController = TextEditingController();
  TextEditingController pwInputController = TextEditingController();

  late String idFinal;
  late String pwFinal;
  late String combiFinal;

  var credentials = <dynamic>{'StoreA_1', 'StoreB_2'};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            //ID input
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                child: TextField(
                  controller: idInputController,
                  decoration: const InputDecoration(
                      hintText: '사장님의 식당 이름을 입력해주세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none),
                )),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                child: TextField(
                  controller: pwInputController,
                  decoration: const InputDecoration(
                      hintText: '비밀번호를 입력해주세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none),
                )),
          ),
          const SizedBox(
            height: 100,
          ),
          ElevatedButton(
            onPressed: () async {
              idFinal = idInputController.text;
              pwFinal = pwInputController.text;
              combiFinal = idFinal + '_' + pwFinal;
              if (credentials.contains(combiFinal)) {
                final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString('storeName', idFinal);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Home(storeID: idFinal),
                    ));
              } else {
                showToast();
              }
            },
            child: const Text('Login'),
            style: ElevatedButton.styleFrom(
                primary: Colors.cyan.shade500,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  void showToast() => Fluttertoast.showToast(
      msg: "다시 입력해주세요!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.cyan,
      textColor: Colors.white,
      fontSize: 16.0);
}
