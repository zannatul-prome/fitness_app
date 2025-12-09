import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signup_page.dart'; // start with signup page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Proper Firebase init for web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBuQBBP__fH7_zN74DBchC9dchP6rYI6S0",
      authDomain: "physicalapp-7fd40.firebaseapp.com",
      projectId: "physicalapp-7fd40",
      storageBucket:  "physicalapp-7fd40.firebasestorage.app",
      messagingSenderId: "1045127190992",
      appId: "1:1045127190992:android:c96bbf1a3d16514ab881d5",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Signup/Login',
      theme: ThemeData.dark(),
      home: SignupPage(),
    );
  }
}
