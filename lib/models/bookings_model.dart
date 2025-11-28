import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Bookings {
  int? id;
  int? userId;
  int? routeId;
  double? totalFare;
  String? status;

  Bookings({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.totalFare,
    this.status,
  });

  factory Bookings.fromJson(Map<String, dynamic> json) {
    return Bookings(
      id: json['id'],
      userId: json['user_id'],
      routeId: json['route_id'],
      totalFare: (json['total_fare'] as num).toDouble(),
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'route_id': routeId,
      'total_fare': totalFare,
      'status': status,
    };
  }

  static Future<Map<String, dynamic>> bookSpecificSeat({
    required int userId,
    required int routeId,
    required int seatNumber,
    required int paymentInfoId,
  }) async {
    final resp = await supabase.rpc(
      'book_specific_seat',
      params: {
        'p_user_id': userId,
        'p_route_id': routeId,
        'p_seat_number': seatNumber,
        'p_payment_info_id': paymentInfoId,
      },
    );
    // RPC returns a setof; cast to list and take first row
    if (resp == null) {
      return {'booking_id': null, 'status_message': 'No response'};
    }
    try {
      final rows = List<Map<String, dynamic>>.from(resp as List);
      if (rows.isEmpty) {
        return {'booking_id': null, 'status_message': 'Empty response'};
      }
      return rows.first;
    } catch (e) {
      return {'booking_id': null, 'status_message': e.toString()};
    }
  }

  /// Book multiple seats sequentially and return results per seat
  static Future<List<Map<String, dynamic>>> bookMultipleSeats({
    required int userId,
    required int routeId,
    required List<int> seatNumbers,
    required int paymentInfoId,
  }) async {
    final results = <Map<String, dynamic>>[];
    for (final seat in seatNumbers) {
      final res = await bookSpecificSeat(
        userId: userId,
        routeId: routeId,
        seatNumber: seat,
        paymentInfoId: paymentInfoId,
      );
      results.add({'seat': seat, 'result': res});
    }
    return results;
  }
}
