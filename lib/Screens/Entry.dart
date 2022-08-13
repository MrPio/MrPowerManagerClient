import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Utils/SnackbarGenerator.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';

import '../Utils/api_request.dart';

class Entry extends StatefulWidget {
  const Entry({Key? key}) : super(key: key);

  @override
  _EntryState createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  Widget build(BuildContext context) {
    //StoreKeyValue.removeData("token");
    return Container(
      color: Random.secure().nextInt(2) == 0 ? Colors.blue : Colors.orange,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
          child: Text("Welcome to \r\n MrPower Manager!",
              style: GoogleFonts.lato(
                  //fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.w900),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  void initState() {
    selectRoute(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  void selectRoute(BuildContext context) async {
    final keys = await StoreKeyValue.getKeys();
    var duration =
        (await StoreKeyValue.readStringData('lastPc')) == '' ? 1500 : 250;
    if (keys != null && keys.contains("token")) {
      final token = await StoreKeyValue.readStringData("token");
      requestData(context, HttpType.get, '/login',
          {'token': token, 'imTheClient': 'true'});

      Future.delayed(Duration(milliseconds: duration), () async {
        SnackBarGenerator.makeSnackBar(context, "Welcome back $token!");
        await Navigator.pushNamed(context, '/home');
        selectRoute(context);
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () async {
        SnackBarGenerator.makeSnackBar(
            context, "You need to login or signup first");
        await Navigator.pushNamed(context, '/login');
        selectRoute(context);
      });
    }
  }
}
