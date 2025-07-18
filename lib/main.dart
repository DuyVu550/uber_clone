import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/InfoHandler/app_info.dart';
import 'package:uber_clone/global/global.dart';
import 'package:uber_clone/screen/forgot_password_screen.dart';
import 'package:uber_clone/screen/login_screen.dart';
import 'package:uber_clone/screen/main_screen.dart';
import 'package:uber_clone/screen/register_screen.dart';
import 'package:uber_clone/screen/search_placed_screen.dart';
import 'package:uber_clone/splashScreen/SplashScreen.dart';
import 'package:uber_clone/themeProvider/themeProvider.dart';
import 'package:uber_clone/widgets/pay_fare_amount_dialog.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Firebase.apps.isEmpty){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBvgpaJ16-Kq9T-XFkDmcl9-zKCnhF-tCU",
        appId: "1:168114649559:android:3fb282846e71768a0ff392",
        messagingSenderId: "168114649559",
        databaseURL: "https://trippo-73fd7-default-rtdb.firebaseio.com/",
        projectId: "trippo-73fd7",
      ),
   );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Uber Clone',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: PayFareAmountDialog(),
      ),
    );
  }
}


