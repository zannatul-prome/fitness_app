import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String pass) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signup(String email, String pass) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
