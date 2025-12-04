import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHelper {
  /// Encrypts a password using SHA-256 hashing
  static String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
