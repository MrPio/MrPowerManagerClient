
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
   LoginPage({Key? key}) : super(key: key);
  TextEditingController inputController = TextEditingController();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Future<Map<String, dynamic>> futureResponse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width/10),
              Expanded(
                child: Text(
                    "Gimme your username, we'll check for your pc in our database:",
                    style: GoogleFonts.lato(fontSize: 20),textAlign: TextAlign.center,),
              ),
              SizedBox(width: MediaQuery.of(context).size.width/10),
            ],
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: MediaQuery.of(context).size.width/1.3,
            child: TextField(
              controller: widget.inputController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  hintText: 'token',
                  icon: Icon(Icons.account_box,size: 32)),
              style:  const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 30.0),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
