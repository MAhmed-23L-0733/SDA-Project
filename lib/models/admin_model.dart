import 'package:flutter_template/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Admin extends Users {
  Admin({
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
         role: 'admin',
       );

  @override
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
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
      'role': 'admin',
    };
  }

  // Add a new route
  static Future<int> addRoute({
    required String origin,
    required String destination,
    required DateTime date,
    required String time,
    required int economyTickets,
    required int businessTickets,
    required int firstTickets,
    required double economyPrice,
    required double businessPrice,
    required double firstPrice,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_route',
        params: {
          'p_origin': origin,
          'p_destination': destination,
          'p_date': date.toIso8601String().split('T')[0],
          'p_time': time,
          'p_economy_tickets': economyTickets,
          'p_business_tickets': businessTickets,
          'p_first_tickets': firstTickets,
          'p_economy_price': economyPrice,
          'p_business_price': businessPrice,
          'p_first_price': firstPrice,
        },
      );

      return response as int;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add route: ${e.toString()}');
    }
  }

  // Update an existing route
  static Future<void> updateRoute({
    required int routeId,
    required String origin,
    required String destination,
    required DateTime date,
    required String time,
    required double economyPrice,
    required double businessPrice,
    required double firstPrice,
  }) async {
    try {
      await supabase.rpc(
        'update_route_details_and_prices',
        params: {
          'p_route_id': routeId,
          'p_new_origin': origin,
          'p_new_destination': destination,
          'p_new_date': date.toIso8601String().split('T')[0],
          'p_new_time': time,
          'p_economy_price': economyPrice,
          'p_business_price': businessPrice,
          'p_first_price': firstPrice,
        },
      );
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update route: ${e.toString()}');
    }
  }

  // Delete a route
  static Future<void> deleteRoute(int routeId) async {
    try {
      await supabase.rpc("delete_route", params: {'p_routeid': routeId});
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete route: ${e.toString()}');
    }
  }

  // Get all routes
  static Future<List<Map<String, dynamic>>> getAllRoutes() async {
    try {
      final response = await supabase.from('routes').select().order('date');
      return response;
    } catch (e) {
      throw Exception('Error fetching routes: $e');
    }
  }

  // Get admin dashboard metrics
  static Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      final response = await supabase.rpc('get_admin_metrics').single();
      return response;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch metrics: ${e.toString()}');
    }
  }
}
