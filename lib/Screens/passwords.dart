import 'package:flutter/material.dart';

class Passwords extends StatefulWidget {
  const Passwords({Key? key}) : super(key: key);

  static String token='MrPio',pcName='i7-10750H';

  @override
  _PasswordsState createState() => _PasswordsState();
}

class _PasswordsState extends State<Passwords> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        flexibleSpace: Text('Stored Password'),
      ),
    );
  }
}
