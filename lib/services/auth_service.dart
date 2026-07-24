import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores only salted password hashes, never the plaintext password.
class _Credential {
  const _Credential(this.salt, this.hash);

  final String salt;
  final String hash;

  Map<String, String> toJson() => {'salt': salt, 'hash': hash};

  static _Credential fromJson(Map<String, dynamic> json) =>
      _Credential(json['salt'] as String, json['hash'] as String);
}

class AuthService {
  AuthService._();

  static const _storageKey = 'users_data';
  static Map<String, _Credential> _users = {};

  static Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    final storedUsers = preferences.getString(_storageKey);
    if (storedUsers == null) return;

    try {
      final decodedUsers = jsonDecode(storedUsers) as Map<String, dynamic>;
      _users = decodedUsers.map(
        (name, value) =>
            MapEntry(name, _Credential.fromJson(value as Map<String, dynamic>)),
      );
    } on FormatException {
      await preferences.remove(_storageKey);
    }
  }

  static List<String> get registeredUsers => _users.keys.toList()..sort();

  static bool authenticate(String username, String password) {
    final credential = _users[username];
    if (credential == null) return false;
    return _hash(password, credential.salt) == credential.hash;
  }

  static Future<bool> register(String username, String password) async {
    if (_users.containsKey(username)) return false;

    _users[username] = _newCredential(password);
    await _persist();
    return true;
  }

  static Future<void> deleteUser(String username) async {
    _users.remove(username);
    await _persist();
  }

  static Future<bool> resetPassword(String username, String newPassword) async {
    if (!_users.containsKey(username)) return false;

    _users[username] = _newCredential(newPassword);
    await _persist();
    return true;
  }

  static _Credential _newCredential(String password) {
    final salt = _generateSalt();
    return _Credential(salt, _hash(password, salt));
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  static Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = _users.map(
      (name, credential) => MapEntry(name, credential.toJson()),
    );
    await preferences.setString(_storageKey, jsonEncode(encoded));
  }
}
