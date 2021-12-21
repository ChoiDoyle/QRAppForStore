// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Login'),
      style: ElevatedButton.styleFrom(
          primary: Colors.cyan.shade500,
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
