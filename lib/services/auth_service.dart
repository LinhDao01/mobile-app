import 'package:pocketbase/pocketbase.dart';

import '../models/user.dart';

import 'pocketbase_client.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(event.record == null
              ? null
              : User.fromJson(event.record!.toJson()));
        });
      });
    }
  }

  Future<User> signup(String email, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final record = await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
      });
      // print("User created successfully: ${record.toJson()}");
      return User.fromJson(record.toJson());
    } catch (e) {
      if (e is ClientException) {
        print("PocketBase Error: ${e.response}");
        throw Exception(e.response['message']);
      }
      print("Unexpected Error: $e");
      throw Exception('An error occurred while signing up');
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);

      // print(
      //     "Login success: ${authRecord.toJson()}"
      //     ); // Kiểm tra phản hồi từ PocketBase

      return User.fromJson(authRecord.toJson());
    } catch (e) {
      if (e is ClientException) {
        print(
            "Login failed: ${e.response}"); // In ra lỗi cụ thể từ PocketBase
        throw Exception(e.response['message'] ?? 'Login failed');
      }

      print("Unexpected Error: $e");
      throw Exception('An error occurred while logging in');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  Future<User?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final model = pb.authStore.record;

    if (model == null) {
      return null;
    }

    return User.fromJson(model.toJson());
  }
}
