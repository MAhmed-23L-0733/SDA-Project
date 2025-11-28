import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Discount {
  final int? id;
  final String? code;
  final int? value;
  final DateTime? expiryDate;

  Discount({this.id, this.code, this.value, this.expiryDate});

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      code: json['code'],
      value: json['value'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'value': value,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
    };
  }

  // Validate discount code and return discount value
  static Future<int> validateDiscountCode(String code) async {
    try {
      final response = await supabase.rpc(
        'validate_discount_code',
        params: {'p_code': code},
      );
      return response as int;
    } on PostgrestException catch (e) {
      // Extract the error message from Supabase
      final message = e.message;
      if (message.contains('DISCOUNT_NOT_FOUND')) {
        throw Exception('Discount code does not exist');
      } else if (message.contains('DISCOUNT_EXPIRED')) {
        throw Exception('Discount code has expired');
      } else {
        throw Exception('Invalid discount code');
      }
    } catch (e) {
      throw Exception('Failed to validate discount: ${e.toString()}');
    }
  }

  // Apply discount to original price and return discounted price
  static Future<double> applyDiscount({
    required double originalPrice,
    required String discountCode,
  }) async {
    try {
      // Validate the discount code and get the discount value
      final discountValue = await validateDiscountCode(discountCode);

      // Calculate discounted price
      final discountAmount = (originalPrice * discountValue) / 100;
      final discountedPrice = originalPrice - discountAmount;

      // Ensure price doesn't go below 0
      return discountedPrice < 0 ? 0 : discountedPrice;
    } catch (e) {
      rethrow;
    }
  }

  // Get all discounts (for admin)
  static Future<List<Discount>> getAllDiscounts() async {
    try {
      final response = await supabase
          .from('discounts')
          .select()
          .order('expiry_date', ascending: false);
      return (response as List).map((json) => Discount.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch discounts: ${e.toString()}');
    }
  }

  // Add new discount (admin only)
  static Future<void> addDiscount({
    required String code,
    required int value,
    required DateTime expiryDate,
  }) async {
    try {
      await supabase.from('discounts').insert({
        'code': code,
        'value': value,
        'expiry_date': expiryDate.toIso8601String().split('T')[0],
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation
        throw Exception('Discount code already exists');
      }
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add discount: ${e.toString()}');
    }
  }

  // Delete discount (admin only)
  static Future<void> deleteDiscount(int discountId) async {
    try {
      await supabase.from('discounts').delete().eq('id', discountId);
    } catch (e) {
      throw Exception('Failed to delete discount: ${e.toString()}');
    }
  }
}
