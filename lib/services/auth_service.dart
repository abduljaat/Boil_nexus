import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Save user info to local storage
  Future<void> saveUserInfoLocally(User? user) async {
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_uid', user.uid);
      if (user.displayName != null) {
        await prefs.setString('user_display_name', user.displayName!);
      } else {
        await prefs.remove('user_display_name');
      }
      if (user.photoURL != null) {
        await prefs.setString('user_photo_url', user.photoURL!);
      } else {
        await prefs.remove('user_photo_url');
      }
    } catch (e) {
      print('ERROR saving user info: $e');
    }
  }

  // Load user info from local storage
  Future<Map<String, String>> loadUserInfoLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email') ?? '',
      'uid': prefs.getString('user_uid') ?? '',
      'displayName': prefs.getString('user_display_name') ?? '',
      'photoURL': prefs.getString('user_photo_url') ?? '',
    };
  }

  // Clear user info from local storage
  Future<void> clearUserInfoLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_uid');
    await prefs.remove('user_display_name');
    await prefs.remove('user_photo_url');
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveUserInfoLocally(cred.user);
      return cred;
    } catch (e) {
      throw handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      print('Attempting to create user...');
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User created: \\${cred.user?.uid}');
      await cred.user?.updateDisplayName(name);
      print('Display name updated');
      await saveUserInfoLocally(cred.user);
      print('User info saved locally');
      return cred;
    } catch (e) {
      print('Error in createUserWithEmailAndPassword: $e');
      if (e is FirebaseAuthException) {
        print('FIREBASE ERROR CODE: \\${e.code}');
        print('FIREBASE ERROR MESSAGE: \\${e.message}');
      }
      throw handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        print('Error in GoogleSignIn.signIn(): $e');
        throw 'Failed to connect to Google services. Please try again.';
      }
      if (googleUser == null) throw 'Google sign in aborted';
      GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        print('Error in googleUser.authentication: $e');
        throw 'Failed to authenticate with Google. Please try again.';
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await saveUserInfoLocally(cred.user);
      return cred;
    } catch (e) {
      throw handleAuthException(e, isGoogleSignIn: true);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      await clearUserInfoLocally();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String handleAuthException(dynamic e, {bool isGoogleSignIn = false}) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered. Please log in or use a different email.';
        case 'invalid-email':
          return 'Email address is invalid.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'operation-not-allowed':
          return 'This sign-in method is not allowed.';
        case 'account-exists-with-different-credential':
          return 'This email is registered with a different sign-in method. Please use Google login.';
        case 'network-request-failed':
          return 'Network error occurred. Please check your connection.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    if (e.toString().contains("is not a subtype of type 'PigeonUserDetails?")) {
      return 'An internal error occurred. Please try again or use a different sign-in method.';
    }
    if (isGoogleSignIn && e.toString().contains('PigeonUserDetails')) {
      return 'Google sign-in failed. Please try again.';
    }
    print('Unhandled Auth Error: $e');
    return 'An internal error occurred. Please try again.';
  }
} 