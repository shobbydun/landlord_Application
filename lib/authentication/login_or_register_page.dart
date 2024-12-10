import 'package:flutter/material.dart';
import 'package:landify/authentication/login_page.dart';
import 'package:landify/authentication/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {

  //initially show login page at satrt
  bool showLoginPage = true;

  //toggle btwn login and register page
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(onTap: togglePages);
    } else{
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}