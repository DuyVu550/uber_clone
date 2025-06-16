import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uber_clone/global/global.dart';
import 'package:uber_clone/screen/login_screen.dart';

import '../Assistant_methods/assistant_method.dart';
import '../screen/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime(){
    Timer(Duration(seconds: 3), () async {
      if(await firebaseAuth.currentUser != null){
        currentUser = firebaseAuth.currentUser;
        firebaseAuth.currentUser != null ? AssistantMethod.readCurrentOnlineUserInfo() : null;
        Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Trippo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
