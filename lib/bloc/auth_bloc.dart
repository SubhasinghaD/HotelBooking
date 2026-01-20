import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends ChangeNotifier {
  AuthBloc({required this.firebaseReady}) {
    if (firebaseReady) {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
        _user = user;
        _syncUserRole();
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _role = 'client';
  bool _roleLoading = false;

  bool get signedIn => _user != null;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get roleLoading => _roleLoading;
  String get displayName => _user?.displayName ?? 'Guest';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;
  String? get authError => _authError;

  Future<void> _syncUserRole() async {
    if (_user == null) {
      _role = 'client';
      _roleLoading = false;
      notifyListeners();
      return;
    }

    _roleLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (!doc.exists) {
        await _setUserRole(_user!, 'client');
        _role = 'client';
      } else {
        _role = (doc.data()?['role'] as String?) ?? 'client';
      }
    } catch (e) {
      _role = 'client';
    } finally {
      _roleLoading = false;
      notifyListeners();
    }
  }

  Future<void> _setUserRole(User user, String role,
      {String? name, String? email}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name ?? user.displayName ?? '',
      'email': email ?? user.email ?? '',
      'role': role,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<String> _getUserRole(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return 'client';
    return (doc.data()?['role'] as String?) ?? 'client';
  }

  Future<void> _handleRoleAfterLogin({
    required User user,
    required String expectedRole,
  }) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _setUserRole(user, expectedRole);
      _role = expectedRole;
      notifyListeners();
      return;
    }

    final existingRole = (doc.data()?['role'] as String?) ?? 'client';
    if (existingRole != expectedRole) {
      _authError = 'This account is not ${expectedRole == 'admin' ? 'an admin' : 'a client'}.';
      await FirebaseAuth.instance.signOut();
      _role = 'client';
      notifyListeners();
      return;
    }

    _role = existingRole;
    notifyListeners();
  }

  Future<void> signInWithGoogle({String expectedRole = 'client'}) async {
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

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _handleRoleAfterLogin(user: user, expectedRole: expectedRole);
      }
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
    String expectedRole = 'client',
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

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _handleRoleAfterLogin(user: user, expectedRole: expectedRole);
      }
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String role = 'client',
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
      if (credential.user != null) {
        await _setUserRole(credential.user!, role, name: name, email: email);
        _role = role;
      }
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
      _role = 'client';
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Still sign out from Firebase even if Google sign out fails
      try {
        await FirebaseAuth.instance.signOut();
        _user = null;
        _authError = null;
        _role = 'client';
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
