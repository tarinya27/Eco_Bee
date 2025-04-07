import 'package:new_bee/automation.dart';
import 'package:new_bee/dashboard.dart';
import 'package:new_bee/feeding_history.dart';
import 'package:flutter/material.dart';
import 'package:new_bee/welcome.dart';
import 'package:new_bee/signup.dart';
import 'package:new_bee/signin.dart';
import 'package:new_bee/welcome.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //home: WelcomeScreen(),
      //home: Signup(),
      //home: SignIn(),
      //home: ForgotPass(),
      //home: Dashboard(),
      //home: AutomationScreen(),
      home: FeedingHistoryScreen(), 
    );
  }
}
