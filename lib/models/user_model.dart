import 'package:supabase_flutter/supabase_flutter.dart';

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
      await supabase.rpc(
        'update_user_password',
        params: {
          'p_user_id': userId,
          'p_old_password': oldPassword,
          'p_new_password': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  // Check if user exists by email
  static Future<bool> checkUserExists(String email) async {
    try {
      final response = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Failed to check user: ${e.toString()}');
    }
  }

  // Get security question for account recovery
  static Future<String?> getSecurityQuestion(String email) async {
    try {
      final userResponse = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        return null;
      }

      final recoveryResponse = await supabase
          .from('account_recovery')
          .select('question')
          .eq('user_id', userResponse['id'])
          .maybeSingle();

      return recoveryResponse?['question'] as String?;
    } catch (e) {
      throw Exception('Failed to fetch security question: ${e.toString()}');
    }
  }

  // Verify security answer using the database function
  static Future<String> verifySecurityAnswer(
    String email,
    String answer,
  ) async {
    try {
      final response = await supabase.rpc(
        'account_recovery',
        params: {'user_email': email, 'user_answer': answer},
      );
      return response as String;
    } catch (e) {
      throw Exception('Failed to verify answer: ${e.toString()}');
    }
  }

  // Reset password (without old password, after security question)
  static Future<void> resetPassword(String email, String newPassword) async {
    try {
      await supabase
          .from('users')
          .update({'password': newPassword})
          .eq('email', email);
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Add security question for account recovery
  static Future<void> addSecurityQuestion(
    int userId,
    String question,
    String answer,
  ) async {
    try {
      final response = await supabase.from('account_recovery').insert({
        'user_id': userId,
        'question': question,
        'answer': answer,
      }).select();
      print('Insert response: $response');
    } catch (e) {
      print('Error in addSecurityQuestion: $e');
      throw Exception('Failed to add security question: ${e.toString()}');
    }
  }

  // Check if user has security question set up
  static Future<bool> hasSecurityQuestion(int userId) async {
    try {
      final response = await supabase
          .from('account_recovery')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Failed to check security question: ${e.toString()}');
    }
  }

  // Get predefined security questions
  static List<String> getSecurityQuestions() {
    return [
      'What is your primary school name?',
      'What is your hometown name?',
      'What is your favorite restaurant?',
      'What is your first pet\'s name?',
      'What is your mother\'s maiden name?',
      'What is your favorite movie?',
      'What city were you born in?',
      'What is your favorite book?',
    ];
  }
}
