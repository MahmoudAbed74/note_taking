import 'package:app/addNote.dart';
import 'package:flutter/material.dart';
import 'package:app/auth/log_in.dart';
import 'package:app/auth/sign_up.dart';
import 'package:app/add&removeNote.dart';
// FireBase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//auth
import 'package:firebase_auth/firebase_auth.dart';

bool? IsLogin;
// Register Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Check if user is logged in
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    IsLogin = false;
  } else {
    IsLogin = true;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Set home screen based on login status
      home: IsLogin == false ? log_in() : Home_page(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.blue),
        primaryColor: Colors.amber,
        textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.blue, fontSize: 30),
            labelLarge: TextStyle(color: Colors.black, fontSize: 30),
            bodyMedium: TextStyle(fontSize: 19, color: Colors.black),
            bodySmall: TextStyle(fontSize: 15, color: Colors.red),
            headlineMedium: TextStyle(fontSize: 20, color: Colors.blue),
            headlineLarge: TextStyle(
                fontSize: 25, color: Colors.blue, fontWeight: FontWeight.bold),
            headlineSmall: TextStyle(
                fontSize: 20, color: Colors.blue, fontWeight: FontWeight.w700),
            displayMedium: TextStyle(fontSize: 15, color: Colors.black),
            displayLarge: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w400)),
      ),
      // Define route names
      routes: {
        "Log In": (context) => log_in(),
        "Sign Up": (context) => Sign_up(),
        "Home Page": (context) => Home_page(),
        "add note": (context) => add_note(),
      },
    );
  }
}
