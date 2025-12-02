import 'package:flutter_template/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

final supabase = Supabase.instance.client;

class Customer extends Users {
  Customer({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dob,
    int? gender,
  }) : super(
         id: id,
         firstName: firstName,
         lastName: lastName,
         email: email,
         phone: phone,
         dob: dob,
         gender: gender,
         role: 'customer',
       );
  @override
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      dob: DateTime.parse(json['dob']),
      gender: json['gender'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'dob': dob?.toIso8601String(),
      'gender': gender,
    };
  }

  static Future<List<Map<String, dynamic>>> Register(
    String firstName,
    String lastName,
    String email,
    String password,
    DateTime dob,
    int gender,
    String phone,
    String role,
  ) async {
    try {
      // Hash the password using bcrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final response = await supabase.from('users').insert({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': hashedPassword,
        'dob': dob.toIso8601String(),
        'gender': gender,
        'phone': phone,
        'role': role,
      }).select();

      return response;
    } on PostgrestException catch (e) {
      // Rethrow Supabase database errors with better messages
      if (e.code == '23505') {
        // Unique constraint violation
        throw Exception(
          'This email is already registered. Please use a different email.',
        );
      } else if (e.code == '23502') {
        // Not null violation
        throw Exception('Please fill in all required fields.');
      } else if (e.code == '23503') {
        // Foreign key violation
        throw Exception('Invalid reference data provided.');
      } else {
        throw Exception('Database error: ${e.message}');
      }
    } catch (e) {
      // Rethrow any other errors
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getBookingHistory() async {
    try {
      final response = await supabase.rpc(
        "get_user_history",
        params: {"p_user_id": id},
      );
      return response;
    } catch (e) {
      throw Exception('Error fetching booking history: $e');
    }
  }

  static Future<String> cancelBooking(int bookingID) {
    return supabase
        .rpc('cancel_booking', params: {'p_booking_id': bookingID})
        .then((value) => value as String);
  }
}
