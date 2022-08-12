import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mr_power_manager_client/Pages/login_page.dart';
import 'package:mr_power_manager_client/Pages/signup_page.dart';
import 'package:mr_power_manager_client/Utils/SnackbarGenerator.dart';
import 'package:mr_power_manager_client/Utils/StoreKeyValue.dart';
import 'package:mr_power_manager_client/Utils/size_adjustaments.dart';
import 'package:mr_power_manager_client/Utils/small_utils.dart';

import '../Utils/api_request.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int _currentIndex = 0;
  Color? floatingSignupColor = Colors.grey[700];
  final screens = [
    LoginPage(),
    SignupPage(),
  ];

  @override
  Widget build(BuildContext context) {
    (screens[1] as SignupPage).updateParent = () => setState(() {});
    return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 2,
            stops: const [0.1, 0.5, 0.7, 0.9],
            colors: [
              Colors.grey[850]!,
              Colors.grey[900]!,
              Colors.grey[800]!,
              Colors.grey[700]!,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text("Login/Signup page", style: GoogleFonts.lato()),
          ),
          body: screens[_currentIndex],
          floatingActionButton: Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.yellow),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: adjustSizeHorizontally(context, 68),
                height: adjustSizeHorizontally(context, 68),
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: floatingActionButtonAction,
                    tooltip: _currentIndex == 0 ? 'Connect' : 'Sign up',
                    child: _currentIndex == 0
                        ? const Icon(Icons.laptop_chromebook)
                        : const Icon(Icons.send),
                    backgroundColor: _currentIndex == 0
                        ? Colors.tealAccent
                        : (screens[1] as SignupPage).signupActionButtonColor,
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            iconSize: 34,
            showUnselectedLabels: true,
            unselectedIconTheme: const IconThemeData(size: 28),
            currentIndex: _currentIndex,
            onTap: (_index) {
              setState(() {
                _currentIndex = _index;
              });
            },
            //backgroundColor: _currentIndex==0?Colors.teal[700]:Colors.cyan[800],
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.login),
                  label: "Login",
                  backgroundColor: Colors.deepOrange),
              BottomNavigationBarItem(
                  icon: Icon(Icons.app_registration),
                  label: "Signup",
                  backgroundColor: Colors.cyan),
            ],
          ),
        ));
  }

  void floatingActionButtonAction() {
    if (_currentIndex == 0) {
      if((screens[0] as LoginPage).inputController.text.length<5){
        SnackBarGenerator.makeSnackBar(context, "Username cannot be this short!",color:Colors.red);
        return;
      }
      requestLogin((screens[0] as LoginPage).inputController.text, context);
    } else if (_currentIndex == 1){
      if((screens[1] as SignupPage).usernameController.text!=keepOnlyAlphaNum((screens[1] as SignupPage).usernameController.text)){
        SnackBarGenerator.makeSnackBar(context, "Please use only alphanumeric characters and underscores",color:Colors.orangeAccent);
        return;
      }
      SnackBarGenerator.makeSnackBar(context, "Username cannot be this short!",color:Colors.red);

      if ((screens[1] as SignupPage).validEmail &&
          ((screens[1] as SignupPage).usernameController.text.length > 4)) {
        requestSignup((screens[1] as SignupPage).usernameController.text,
            (screens[1] as SignupPage).emailController.text, context);
      } else {
        return;
      }
    }
    SnackBarGenerator.makeSnackBar(context, 'Please wait...',
        fontSize: 16, color: Colors.yellow,millis: 10000);
  }

  void requestLogin(String token, BuildContext context) async {
    final response = await requestData(
        context, HttpType.get, '/login', {'token': token,'imTheClient':'true'});

    if (response.keys.isNotEmpty) {
      if (response['result']
          .toString()
          .contains('user present in database!')) {
        SnackBarGenerator.makeSnackBar(context, "Welcome back $token!",
            color: Colors.cyan, fontSize: 16);
        StoreKeyValue.saveData('token', token);
        Future.delayed(const Duration(seconds: 1), () async {
          Navigator.pushNamed(context, "/");
        });
      } else {
        SnackBarGenerator.makeSnackBar(
            context, response['result'].toString(),
            color: Colors.cyan, fontSize: 16);
      }
    } else {
      throw Exception('Failed to contact the server');
    }
  }

  void requestSignup(
      String username, String email, BuildContext context) async {
    final response =await requestData(context, HttpType.post, '/signup',
    {
      'token':username,
      'email':email
    });

    if (response.isNotEmpty) {
      if (response['result']
          .toString()
          .contains('user already in database')) {
        SnackBarGenerator.makeSnackBar(
            context, "This username is already in use!",
            color: Colors.deepOrange, fontSize: 16);
      } else if (response['result']
          .toString()
          .contains('user registered successfully')) {
        SnackBarGenerator.makeSnackBar(context, "Welcome $username!",
            color: Colors.cyan, fontSize: 16);
        StoreKeyValue.saveData('token', username);
        StoreKeyValue.saveData('email', email);
        Future.delayed(const Duration(seconds: 1), () async {
          Navigator.pushNamed(context, "/");
        });
      }
      // SnackBarGenerator.makeSnackBar(context, mapResponse.values.first,
      //     color: Colors.cyan, fontSize: 16);
    } else {
      throw Exception('Failed to contact the server');
    }
  }
}
