import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class RevenueInfo {
  final int bookingId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final int routeId;
  final int? ticketId;
  final int? seatNumber;
  final String? ticketClass;
  final int paidAmount;
  final String bookingStatus;
  final DateTime bookingDate;

  RevenueInfo({
    required this.bookingId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.routeId,
    this.ticketId,
    this.seatNumber,
    this.ticketClass,
    required this.paidAmount,
    required this.bookingStatus,
    required this.bookingDate,
  });

  factory RevenueInfo.fromMap(Map<String, dynamic> map) {
    return RevenueInfo(
      bookingId: map['booking_id'] as int,
      customerName: map['customer_name'] as String? ?? 'N/A',
      customerEmail: map['customer_email'] as String? ?? 'N/A',
      customerPhone: map['customer_phone'] as String? ?? 'N/A',
      routeId: map['route_id'] as int,
      ticketId: map['ticket_id'] as int?,
      seatNumber: map['seat_number'] as int?,
      ticketClass: map['ticket_class'] as String?,
      paidAmount: map['paid_amount'] as int,
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
}
