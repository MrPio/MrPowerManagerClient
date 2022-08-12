import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_power_manager_client/Utils/api_request.dart';

import '../Styles/background_gradient.dart';
import '../Utils/StoreKeyValue.dart';

class AddPc extends StatefulWidget {
  AddPc({Key? key}) : super(key: key);
  String code = "123456";
  bool waiting = true;
  String pcName = '';

  @override
  _AddPcState createState() => _AddPcState();
}

class _AddPcState extends State<AddPc> {
  @override
  Widget build(BuildContext context) {
    var settings =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    widget.pcName = settings['pcName'] ?? '';
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 4,
          stops: const [0.0, 0.2],
          colors: widget.waiting?[
            Colors.grey[800]!,
            Colors.grey[900]!,
          ]:[
            Colors.blue[900]?.withOpacity(0.7)??Colors.blue,
            Colors.black,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: widget.waiting ? wait() : code()),
      ),
    );
  }

  wait() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          strokeWidth: 6,
          color: Colors.blue,
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Please wait...",
          style: GoogleFonts.lato(fontSize: 26),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  code() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Here your code, it will expire in 5 minutes... Hurry!",
          style: GoogleFonts.lato(fontSize: 26),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 60,
        ),
        Text(
          widget.code,
          style: const TextStyle(
            fontFamily: 'lcd',
            fontSize: 64,
            color: Colors.lightBlue,
            letterSpacing: 24,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30,),
        ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              "CONFIRM",
              style: GoogleFonts.lato(fontSize: 26,color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/home');
          },
          style: ElevatedButton.styleFrom(
            elevation: 4,
            primary: Colors.blue[800]?.withOpacity(0.8),
            onPrimary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1300), () async {
      var args = {'token': await StoreKeyValue.readStringData('token'), 'pcName': widget.pcName};
      var response =
          await requestData(context, HttpType.get, '/requestCode', args);
      print(response.toString());
      setState(() {
        widget.waiting = false;
        widget.code = response['code'];
      });
    });
  }
}
