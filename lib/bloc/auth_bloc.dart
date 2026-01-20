import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends ChangeNotifier {
  AuthBloc({required this.firebaseReady}) {
    if (firebaseReady) {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
        _user = user;
        notifyListeners();
      });
    } else {
      _authError =
          'Firebase is not configured. Add your web config in AppConfig.';
    }
  }

  final bool firebaseReady;
  StreamSubscription<User?>? _authSub;
  User? _user;
  String? _authError;

  bool get signedIn => _user != null;
  String get displayName => _user?.displayName ?? 'Guest';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;
  String? get authError => _authError;

  Future<void> signInWithGoogle() async {
    if (!firebaseReady) {
      _authError =
          'Firebase is not configured. Add your web config in AppConfig.';
      notifyListeners();
      return;
    }

    _authError = null;
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (!firebaseReady) {
      _authError =
          'Firebase is not configured. Add your web config in AppConfig.';
      notifyListeners();
      return;
    }

    _authError = null;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!firebaseReady) {
      _authError =
          'Firebase is not configured. Add your web config in AppConfig.';
      notifyListeners();
      return;
    }

    _authError = null;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    
    try {
      // Only sign out from Google if on web (where it works)
      if (kIsWeb) {
        // On web, just use Firebase Auth, skip Google Sign In
        await FirebaseAuth.instance.signOut();
      } else {
        // On mobile, sign out from both
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
      }
      
      _user = null;
      _authError = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Still sign out from Firebase even if Google sign out fails
      try {
        await FirebaseAuth.instance.signOut();
        _user = null;
        _authError = null;
        notifyListeners();
      } catch (e2) {
        debugPrint('Error signing out from Firebase: $e2');
      }
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
