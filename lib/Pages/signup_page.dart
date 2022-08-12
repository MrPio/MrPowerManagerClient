import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupPage extends StatefulWidget {

  SignupPage({Key? key}) : super(key: key);
  Function updateParent=() => {};
  TextEditingController emailController = TextEditingController(),
      usernameController = TextEditingController();
  bool validEmail = false;
  Color? signupActionButtonColor = Colors.grey[700];

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.3,
              child: TextField(
                controller: widget.emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    hintText: 'e-mail',
                    iconColor: Colors.amber,
                    icon: Icon(Icons.alternate_email, size: 32)),
                style: const TextStyle(
                  fontSize: 18,
                ),
                readOnly: true,
                onTap: ()async=>await requestGoogleEmail(),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.3,
              child: TextField(
                controller: widget.usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    hintText: 'username',
                    iconColor: Colors.amber,
                    icon: Icon(Icons.account_box, size: 32)),
                style: const TextStyle(
                  fontSize: 18,
                ),
                enabled: widget.validEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    widget.usernameController.addListener(() {
      Color? color;
      if (widget.usernameController.text.length > 4) {
        color = Colors.cyanAccent;
        print('eccomi!');
      } else {
        color = Colors.grey[700];
      }
      setState(() {
        widget.signupActionButtonColor = color;
        widget.updateParent();
      });
    });
  }

  requestGoogleEmail() async {
    try {
      var google = await _googleSignIn.signIn();
      if (google != null) {
        setState(() {
          print(google.email);
          widget.emailController.text = google.email;
          widget.validEmail = true;
        });
      }
    } catch (error) {
      print(error);
    }
  }
}
