import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

final supabase = Supabase.instance.client;

class Users {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  DateTime? dob;
  int? gender;
  String? role;

  // 1. Standard Constructor
  Users({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.id,
    required this.role,
  });
  // 2. "Factory" Constructor (Converts JSON from Supabase -> Dart Object)
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      dob: DateTime.parse(json['dob']),
      gender: json['gender'],
      role: json['role'],
    );
  }

  // 3. Method to convert Dart Object -> JSON (for sending data TO Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'role': role,
      // 'id' and 'created_at' are usually handled by the database automatically
    };
  }

  // Update user profile
  static Future<void> updateProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required DateTime dob,
    required int gender,
  }) async {
    try {
      await supabase
          .from('users')
          .update({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone': phone,
            'dob': dob.toIso8601String(),
            'gender': gender,
          })
          .eq('id', userId);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('This email is already registered.');
      } else {
        throw Exception('Database error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Update user password
  static Future<void> updatePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // First, get the current hashed password from database to verify old password
      final userResponse = await supabase
          .from('users')
          .select('password')
          .eq('id', userId)
          .single();

      final storedHashedPassword = userResponse['password'] as String;

      // Verify old password
      final isOldPasswordValid = BCrypt.checkpw(
        oldPassword,
        storedHashedPassword,
      );

      if (!isOldPasswordValid) {
        throw Exception('Current password is incorrect');
      }

      // Hash the new password
      final hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      // Update with hashed password
      await supabase
          .from('users')
          .update({'password': hashedNewPassword})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }
}
