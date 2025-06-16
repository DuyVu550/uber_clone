import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/global/global.dart';
import 'package:uber_clone/screen/forgot_password_screen.dart';
import 'package:uber_clone/screen/login_screen.dart';
import 'package:uber_clone/screen/main_screen.dart';
import 'package:uber_clone/screen/register_screen.dart';
import 'package:uber_clone/splashScreen/SplashScreen.dart';
import 'package:uber_clone/themeProvider/themeProvider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: const FirebaseOptions(
      apiKey: "AIzaSyCGETeL_KuN9iMwgEV6hjg6GiRtWijfNzA",
      appId: "1:168114649559:android:3fb282846e71768a0ff392",
      messagingSenderId: "168114649559",
      databaseURL: "https://trippo-73fd7-default-rtdb.firebaseio.com",
      projectId: "trippo-73fd7",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: MainScreen(),
    );
  }
}


