import 'package:flutter/material.dart';
import 'package:uber_clone/screen/main_page.dart';
import 'package:uber_clone/screen/register_screen.dart';
import 'package:uber_clone/themeProvider/themeProvider.dart';

void main() {
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
      home: RegisterScreen(),
    );
  }
}


