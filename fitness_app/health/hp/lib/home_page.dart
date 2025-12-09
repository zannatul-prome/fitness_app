import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool showWelcomeSnack;

  HomePage({required this.userData, this.showWelcomeSnack = true});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Show welcome SnackBar only once
    if (widget.showWelcomeSnack) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Signup Successful! Welcome, ${widget.userData['name']}!"),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${widget.userData['name']}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${widget.userData['email']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to login or previous page
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
