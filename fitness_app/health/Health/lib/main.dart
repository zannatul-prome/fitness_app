import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signup_page.dart';
import 'wrapper_screen.dart';
import 'home_page.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBuQBBP__fH7_zN74DBchC9dchP6rYI6S0",
      authDomain: "physicalapp-7fd40.firebaseapp.com",
      projectId: "physicalapp-7fd40",
      storageBucket: "physicalapp-7fd40.firebasestorage.app",
      messagingSenderId: "1045127190992",
      appId: "1:1045127190992:android:c96bbf1a3d16514ab881d5",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const WrapperScreen(),
        '/home': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
      },
    );
  }
}