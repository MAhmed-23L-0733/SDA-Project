import 'package:flutter_template/main.dart';

class Ticket {
  int? id;
  int? routeId;
  double? price;
  int? status; // 1 = available, 2 = sold
  int? seatNumber;
  String? Class;
  String? discountCode;

  Ticket({
    this.id,
    this.routeId,
    this.price,
    this.status,
    this.seatNumber,
    this.Class,
    this.discountCode,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] is int ? json['id'] as int : (json['id'] as num?)?.toInt(),
      routeId: json['route_id'] is int
          ? json['route_id'] as int
          : (json['route_id'] as num?)?.toInt(),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: json['status'] is int
          ? json['status'] as int
          : (json['status'] as num?)?.toInt(),
      seatNumber: json['seat_number'] is int
          ? json['seat_number'] as int
          : (json['seat_number'] as num?)?.toInt(),
      Class: json['class'],
      discountCode: json['discount_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'price': price,
      'status': status,
      'seat_number': seatNumber,
      'class': Class,
      'discount_code': discountCode,
    };
  }

  /// Fetch tickets using the provided RPC `get_tickets_by_route`
  static Future<List<Ticket>> fetchByRoute(int routeId) async {
    final resp = await supabase.rpc(
      'get_tickets_by_route',
      params: {'p_route_id': routeId},
    );
    if (resp == null) return [];
    final list = List<Map<String, dynamic>>.from(resp as List);
    return list.map((e) => Ticket.fromJson(e)).toList();
  }

  /// Update discount code for a specific ticket
  static Future<void> updateDiscountCode(
    int ticketId,
    String? discountCode,
  ) async {
    await supabase
        .from('tickets')
        .update({'discount_code': discountCode})
        .eq('id', ticketId);
  }

  /// Update discount code for multiple tickets
  static Future<void> updateDiscountCodesForTickets(
    List<int> ticketIds,
    String? discountCode,
  ) async {
    await supabase
        .from('tickets')
        .update({'discount_code': discountCode})
        .inFilter('id', ticketIds);
  }
}
