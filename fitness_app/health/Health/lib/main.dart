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
      apiKey: "AIzaSyCoYfXaYK9gr4OhCa8EG815y0jmOMi-R3k",
      authDomain: "healthapp-92bcb.firebaseapp.com",
      projectId: "healthapp-92bcb",
      storageBucket: "healthapp-92bcb.firebasestorage.app",
      messagingSenderId: "81675946284",
      appId: "1:81675946284:android:69734500f21f3c419c0489",
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