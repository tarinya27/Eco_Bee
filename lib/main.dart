import 'package:bee_feeder_ui/automation.dart';
import 'package:bee_feeder_ui/dashboard.dart';
import 'package:bee_feeder_ui/feeding_history.dart';
import 'package:flutter/material.dart';
import 'package:bee_feeder_ui/welcome.dart';
import 'package:bee_feeder_ui/signup.dart';
import 'package:bee_feeder_ui/signin.dart';
import 'package:bee_feeder_ui/forpass.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // home: WelcomeScreen(),
        home: Signup(),
      //home: Signin(),
      //home: ForgotPass(),
      //home: Dashboard(),
      //home: AutomationScreen(),
      //home: FeedingHistoryScreen(), 
    );
  }
}
