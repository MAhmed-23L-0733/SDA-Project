import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Routes {
  int? id;
  DateTime? date;
  String? origin;
  String? destination;
  String? time;

  Routes({
    this.id,
    required this.date,
    required this.origin,
    required this.destination,
    required this.time,
  });
  factory Routes.fromJson(Map<String, dynamic> json) {
    return Routes(
      id: json['id'] is int ? json['id'] as int : (json['id'] as num?)?.toInt(),
      date: DateTime.parse(json['date']),
      origin: json['origin'],
      destination: json['destination'],
      time: json['time'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'origin': origin,
      'destination': destination,
      'time': time,
    };
  }

  static Future<List<Map<String, dynamic>>> FetchData() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('routes')
          .select();

      return response;
    } catch (e) {
      throw Exception('Error fetching routes: $e');
    }
  }
}
