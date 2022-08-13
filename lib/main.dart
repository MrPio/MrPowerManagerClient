import 'package:flutter/material.dart';
import 'package:mr_power_manager_client/Screens/Entry.dart';
import 'package:mr_power_manager_client/Screens/Home.dart';
import 'package:mr_power_manager_client/Screens/Login.dart';
import 'package:mr_power_manager_client/Screens/Signup.dart';
import 'package:mr_power_manager_client/Screens/add_pc.dart';
import 'package:mr_power_manager_client/Screens/pc_manager.dart';
import 'package:mr_power_manager_client/Screens/test.dart';
import 'package:mr_power_manager_client/Screens/webcam_streaming.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';

import 'Screens/keyboard_listner.dart';
import 'Screens/wattage_consumption.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // StoreKeyValue.removeData('token');
    // StoreKeyValue.removeData('email');
    // StoreKeyValue.saveData('token', 'MrPio'); //<-------TODO
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData.dark(),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => Entry(), //<-- TODO
        '/login': (BuildContext context) => Login(),
        '/signup': (BuildContext context) => const Signup(),
        '/home': (BuildContext context) => Home(),
        '/pcManager': (BuildContext context) => PcManager(),
        '/test': (BuildContext context) => const Test(),
        '/addPc': (BuildContext context) => AddPc(),
        '/keyboardListener': (BuildContext context) => MyKeyboardListener(),
        '/webcamStreaming': (BuildContext context) => WebcamStreaming(),
      },
    );
  }
}
