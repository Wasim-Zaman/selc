import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 1. Use singleton instance (Unnamed constructor was removed in v7)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  // 2. Explicit initialization is required before performing auth calls
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  // Method to handle Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // 3. authenticate() replaces signIn() and opens the native account picker
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      log('Google User: $googleUser');

      // 4. Retrieve ID token synchronously from account authentication
      final String? idToken = googleUser.authentication.idToken;

      // 5. Explicitly authorize scopes to obtain the Access Token
      final authorizationClient = googleUser.authorizationClient;
      final authorization = await authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // 6. Construct Firebase OAuthCredential with both retrieved tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      // 7. Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Return the signed-in user
      return userCredential.user;
    } catch (e) {
      log('Error signing in with Google: $e');
      return null;
    }
  }

  // Method to sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      log('Error signing out: $e');
    }
  }

  // Method to check if the user is signed in
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
