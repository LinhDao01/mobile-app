import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;

  User? _loggedInUser;

  AuthManager() {
    _authService = AuthService(onAuthChange: (User? user) {
      _loggedInUser = user;
      notifyListeners();
    });
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  Future<User> signup(String email, String password) {
    // _loggedInUser = User(
    //   id: '1',
    //   username: 'test',
    //   email: email,
    // );
    // notifyListeners();
    // return Future.value(_loggedInUser);
    return _authService.signup(email, password);
  }

  Future<User> login(String email, String password) {
    // _loggedInUser = User(
    //   id: '1',
    //   username: 'test',
    //   email: email,
    // );
    // notifyListeners();
    // return Future.value(_loggedInUser);
    return _authService.login(email, password);
  }

  Future<void> tryAutoLogin() async {
    // return Future.value();
    final user = await _authService.getUserFromStore();
    if (_loggedInUser != null) {
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // _loggedInUser = null;
    // notifyListeners();
    // return Future.value();
    return _authService.logout();
  }
}
