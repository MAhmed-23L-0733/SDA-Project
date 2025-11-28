import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PaymentInfo {
  int? id;
  int? userId;
  String? cardNumber; // Last 4 digits for display
  String? cardNumberFull; // Full card number (for new cards only)
  int? mpin;
  DateTime? expiryDate;
  int? secretCode;
  DateTime? createdAt;

  PaymentInfo({
    this.id,
    this.userId,
    this.cardNumber,
    this.cardNumberFull,
    this.mpin,
    this.expiryDate,
    this.secretCode,
    this.createdAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    // Get full card number and mask it for display
    final fullCardNumber = json['card_number']?.toString() ?? '';
    final maskedCard = fullCardNumber.length >= 4
        ? '**** **** **** ${fullCardNumber.substring(fullCardNumber.length - 4)}'
        : fullCardNumber;

    return PaymentInfo(
      id: json['id'],
      userId: json['user_id'],
      cardNumber: maskedCard,
      mpin: json['mpin'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      secretCode: json['secret_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_number': cardNumberFull ?? cardNumber,
      'mpin': mpin,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'secret_code': secretCode,
    };
  }

  // Get all payment methods for a user
  static Future<List<PaymentInfo>> getUserPaymentMethods(int userId) async {
    try {
      final response = await supabase
          .from('paymentInfo')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentInfo.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payment methods: ${e.toString()}');
    }
  }

  // Add new payment method
  static Future<PaymentInfo> addPaymentMethod({
    required int userId,
    required String cardNumber,
    required int mpin,
    required DateTime expiryDate,
    required int secretCode,
  }) async {
    try {
      final response = await supabase
          .from('paymentInfo')
          .insert({
            'user_id': userId,
            'card_number': int.parse(cardNumber.replaceAll(' ', '')),
            'mpin': mpin,
            'expiry_date': expiryDate.toIso8601String().split('T')[0],
            'secret_code': secretCode,
          })
          .select()
          .single();

      return PaymentInfo.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add payment method: ${e.toString()}');
    }
  }

  // Delete payment method
  static Future<void> deletePaymentMethod(int paymentInfoId) async {
    try {
      await supabase.from('paymentInfo').delete().eq('id', paymentInfoId);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete payment method: ${e.toString()}');
    }
  }

  // Get card type from card number
  static String getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'American Express';
    }
    return 'Card';
  }
}

class Payment {
  int? id;
  int? userId;
  int? paymentInfoId;
  double? amount;
  int? bookingsId;
  DateTime? createdAt;

  Payment({
    this.id,
    this.userId,
    this.paymentInfoId,
    this.amount,
    this.bookingsId,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      paymentInfoId: json['payment_info_id'],
      amount: json['amount']?.toDouble(),
      bookingsId: json['bookings_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payment_info_id': paymentInfoId,
      'amount': amount,
      'bookings_id': bookingsId,
    };
  }

  // Get payment details for a booking
  static Future<Payment?> getPaymentByBookingId(int bookingId) async {
    try {
      final response = await supabase
          .from('payments')
          .select()
          .eq('bookings_id', bookingId)
          .maybeSingle();

      if (response == null) return null;
      return Payment.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch payment: ${e.toString()}');
    }
  }
}
