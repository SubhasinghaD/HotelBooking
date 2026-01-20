import 'package:flutter/foundation.dart';

class AuthBloc extends ChangeNotifier {
  bool _signedIn = false;
  String _displayName = 'Guest';

  bool get signedIn => _signedIn;
  String get displayName => _displayName;

  void signInMock(String name) {
    _signedIn = true;
    _displayName = name;
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    _displayName = 'Guest';
    notifyListeners();
  }
}
