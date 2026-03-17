import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final _auth   = FirebaseAuth.instance;
  final _google = GoogleSignIn();

  bool get isLoggedIn => _auth.currentUser != null;

  Map<String, dynamic>? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return {
      'uid':         u.uid,
      'email':       u.email ?? '',
      'displayName': u.displayName ?? 'ผู้ใช้งาน',
      'photoURL':    u.photoURL ?? '',
    };
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) throw Exception('ยกเลิกการเข้าสู่ระบบ');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    return currentUser!;
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<bool> restoreSession() async {
    return _auth.currentUser != null;
  }
}