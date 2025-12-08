import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class RevenueInfo {
  final int bookingId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? routeOrigin;
  final String? routeDestination;
  final DateTime? travelDate;
  final String? travelTime;
  final int? seatNumber;
  final String? ticketClass;
  final String? discountCode;
  final double paidAmount;
  final int? cardNumber;
  final String bookingStatus;
  final DateTime bookingDate;

  RevenueInfo({
    required this.bookingId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.routeOrigin,
    this.routeDestination,
    this.travelDate,
    this.travelTime,
    this.seatNumber,
    this.ticketClass,
    this.discountCode,
    required this.paidAmount,
    this.cardNumber,
    required this.bookingStatus,
    required this.bookingDate,
  });

  factory RevenueInfo.fromMap(Map<String, dynamic> map) {
    return RevenueInfo(
      bookingId: map['booking_id'] as int,
      customerName: map['customer_name'] as String? ?? 'N/A',
      customerEmail: map['customer_email'] as String? ?? 'N/A',
      customerPhone: map['customer_phone'] as String? ?? 'N/A',
      routeOrigin: map['route_origin'] as String?,
      routeDestination: map['route_destination'] as String?,
      travelDate: map['travel_date'] != null
          ? DateTime.parse(map['travel_date'] as String)
          : null,
      travelTime: map['travel_time'] as String?,
      seatNumber: map['seat_number'] as int?,
      ticketClass: map['ticket_class'] as String?,
      discountCode: map['discount_code'] as String?,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      cardNumber: map['card_number'] as int?,
      bookingStatus: map['booking_status'] as String,
      bookingDate: DateTime.parse(map['booking_date'] as String),
    );
  }

  static Future<List<RevenueInfo>> fetchAllRevenue() async {
    try {
      final response = await supabase.rpc('revenue_info');

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => RevenueInfo.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch revenue info: ${e.toString()}');
    }
  }

  String getStatusColor() {
    switch (bookingStatus.toLowerCase()) {
      case 'confirmed':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'pending':
        return 'orange';
      default:
        return 'grey';
    }
  }

  String getRouteDisplay() {
    if (routeOrigin != null && routeDestination != null) {
      return '$routeOrigin → $routeDestination';
    }
    return 'N/A';
  }

  String getMaskedCardNumber() {
    if (cardNumber == null) return 'N/A';
    final cardStr = cardNumber.toString();
    if (cardStr.length >= 4) {
      return '**** **** **** ${cardStr.substring(cardStr.length - 4)}';
    }
    return cardStr;
  }
}
