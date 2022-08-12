import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_power_manager_client/Utils/SnackbarGenerator.dart';

import '../Styles/background_gradient.dart';
class MyKeyboardListener extends StatefulWidget {
  const MyKeyboardListener({Key? key}) : super(key: key);

  @override
  _MyKeyboardListenerState createState() => _MyKeyboardListenerState();
}

class _MyKeyboardListenerState extends State<MyKeyboardListener> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        child: Container(
          decoration: getBackgroundGradient(),
          child: const Scaffold(
            body: TextField(),
          ),
        )      ,
        onKey: (value) {
          SnackBarGenerator.makeSnackBar(context, (value.logicalKey.keyLabel),millis: 300);
          if(value is! RawKeyDownEvent) {
            return;
          }
        },

      ),
    );
  }
}
