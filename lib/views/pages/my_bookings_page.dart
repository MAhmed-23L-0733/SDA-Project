import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_template/data/notifiers.dart';
import 'package:flutter_template/models/customer_model.dart';
import 'package:flutter_template/models/notification_model.dart';
import 'package:flutter_template/models/routes_model.dart';
import 'package:flutter_template/models/discount_model.dart';
import 'package:flutter_template/models/payment_model.dart';
import 'package:flutter_template/views/pages/route_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;
  Map<String, int> _discountValues = {}; // Cache for discount values
  Map<int, PaymentInfo> _paymentInfoCache = {}; // Cache for payment info

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await customerNotifier.value.getBookingHistory();

      if (!mounted) return;

      setState(() {
        _bookings = response.map((e) => e as Map<String, dynamic>).toList();
        _isLoading = false;
      });

      // Load discount values for bookings with discount codes
      await _loadDiscountValues();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDiscountValues() async {
    for (var booking in _bookings) {
      final discountCode = booking['discount_code'];
      if (discountCode != null && !_discountValues.containsKey(discountCode)) {
        try {
          final value = await Discount.validateDiscountCode(discountCode);
          if (mounted) {
            setState(() {
              _discountValues[discountCode] = value;
            });
          }
        } catch (e) {
          // If discount is expired or invalid, skip it
        }
      }
    }

    // Load payment info for each booking
    await _loadPaymentInfo();
  }

  Future<void> _loadPaymentInfo() async {
    for (var booking in _bookings) {
      final bookingId = booking['booking_id'];
      if (bookingId != null && !_paymentInfoCache.containsKey(bookingId)) {
        try {
          // Get payment record for this booking
          final payment = await Payment.getPaymentByBookingId(bookingId);
          if (payment != null && payment.paymentInfoId != null) {
            // Fetch the payment info details
            final paymentInfoResponse = await supabase
                .from('paymentInfo')
                .select()
                .eq('id', payment.paymentInfoId!)
                .maybeSingle();

            if (paymentInfoResponse != null && mounted) {
              final paymentInfo = PaymentInfo.fromJson(paymentInfoResponse);
              setState(() {
                _paymentInfoCache[bookingId] = paymentInfo;
              });
            }
          }
        } catch (e) {
          // Skip if payment info not found
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading bookings',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadBookings,
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _bookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 80,
                      color: Color.fromRGBO(
                        theme.colorScheme.primary.red,
                        theme.colorScheme.primary.green,
                        theme.colorScheme.primary.blue,
                        0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No bookings yet',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your booking history will appear here',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadBookings,
                color: theme.colorScheme.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return _buildBookingCard(booking, isDark, theme);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    bool isDark,
    ThemeData theme,
  ) {
    final bookingId = booking['booking_id'];
    final routeId = booking['route_id'];
    final route = booking['route'] ?? 'Unknown Route';
    final travelDate = booking['travel_date'] != null
        ? DateTime.parse(booking['travel_date'])
        : null;
    final seatNumber = booking['seat_number'];
    final originalPrice = booking['price'];
    final discountCode = booking['discount_code'];
    final seatClass = booking['class'] ?? 'N/A';
    final bookingStatus = booking['status'] ?? 'confirmed';
    final bookedOn = booking['booked_on'] != null
        ? DateTime.parse(booking['booked_on'])
        : null;

    // Calculate discounted price if discount code exists
    double? displayPrice = originalPrice?.toDouble();
    int? discountPercent;
    double? discountAmount;

    if (discountCode != null &&
        originalPrice != null &&
        _discountValues.containsKey(discountCode)) {
      discountPercent = _discountValues[discountCode];
      if (discountPercent != null) {
        discountAmount = (originalPrice * discountPercent) / 100;
        displayPrice = originalPrice - discountAmount;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Color.fromRGBO(
              theme.colorScheme.primary.red,
              theme.colorScheme.primary.green,
              theme.colorScheme.primary.blue,
              0.3,
            ),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with booking ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            theme.colorScheme.primary.red,
                            theme.colorScheme.primary.green,
                            theme.colorScheme.primary.blue,
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.confirmation_number,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking #$bookingId',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (bookedOn != null)
                            Text(
                              'Booked on ${_formatDate(bookedOn)}',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(bookingStatus),
                ],
              ),
              const SizedBox(height: 20),

              // Route information
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Divider(
                color: Color.fromRGBO(
                  theme.colorScheme.primary.red,
                  theme.colorScheme.primary.green,
                  theme.colorScheme.primary.blue,
                  0.2,
                ),
              ),
              const SizedBox(height: 16),

              // Details row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      Icons.event,
                      'Travel Date',
                      travelDate != null ? _formatDate(travelDate) : 'N/A',
                      isDark,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      Icons.event_seat,
                      'Seat',
                      seatNumber != null ? 'Seat $seatNumber' : 'N/A',
                      isDark,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payments,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fare',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (discountCode != null &&
                            discountPercent != null) ...[
                          Text(
                            'PKR ${originalPrice?.toInt()}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            'PKR ${displayPrice?.toInt()}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else
                          Text(
                            displayPrice != null
                                ? 'PKR ${displayPrice.toInt()}'
                                : 'N/A',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Show discount info if applied
              if (discountCode != null && discountPercent != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 255, 0, 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 255, 0, 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.discount, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Discount "$discountCode" applied: $discountPercent% OFF (Saved PKR ${discountAmount?.toInt()})',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Show payment card info if available
              if (_paymentInfoCache.containsKey(bookingId)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paid with ${PaymentInfo.getCardType(_paymentInfoCache[bookingId]!.cardNumber ?? '')} ${_paymentInfoCache[bookingId]!.cardNumber ?? ''}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Class information and Action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildClassBadge(seatClass, theme),
                  _buildActionButton(
                    bookingStatus,
                    bookingId,
                    routeId,
                    booking,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String status,
    int bookingId,
    int? routeId,
    Map<String, dynamic> booking,
  ) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return ElevatedButton.icon(
          onPressed: () => _cancelBooking(bookingId),
          icon: Icon(Icons.cancel_outlined, size: 20),
          label: Text(
            'Cancel Booking',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.red, width: 2),
                ),
                elevation: 2,
              ).copyWith(
                overlayColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return null;
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return Colors.red;
                }),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.red;
                  }
                  return Colors.white;
                }),
                side: MaterialStateProperty.resolveWith<BorderSide>((
                  Set<MaterialState> states,
                ) {
                  return BorderSide(color: Colors.red, width: 2);
                }),
              ),
        );
      case 'cancelled':
        return ElevatedButton.icon(
          onPressed: () => _bookAgain(routeId),
          icon: Icon(Icons.refresh, size: 20),
          label: Text(
            'Book Again',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue, width: 2),
                ),
                elevation: 2,
              ).copyWith(
                overlayColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return null;
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return Colors.blue;
                }),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.blue;
                  }
                  return Colors.white;
                }),
                side: MaterialStateProperty.resolveWith<BorderSide>((
                  Set<MaterialState> states,
                ) {
                  return BorderSide(color: Colors.blue, width: 2);
                }),
              ),
        );
      case 'pending':
        return ElevatedButton.icon(
          onPressed: () => _goToPayment(booking),
          icon: Icon(Icons.payment, size: 20),
          label: Text(
            'Pay Now',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.orange, width: 2),
                ),
                elevation: 2,
              ).copyWith(
                overlayColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return null;
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white;
                  }
                  return Colors.orange;
                }),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.orange;
                  }
                  return Colors.white;
                }),
                side: MaterialStateProperty.resolveWith<BorderSide>((
                  Set<MaterialState> states,
                ) {
                  return BorderSide(color: Colors.orange, width: 2);
                }),
              ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Cancelling booking...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Call backend function
      final result = await Customer.cancelBooking(bookingId);

      if (!mounted) return;

      // Check if cancellation was successful
      final isSuccess = result.toLowerCase().contains('success');

      // Create notification for the cancellation action
      if (isSuccess && customerNotifier.value.id != null) {
        await NotificationService.createActionNotification(
          userId: customerNotifier.value.id!,
          type: NotificationType.cancellation,
          title: 'Booking Cancelled',
          message: 'Your booking has been successfully cancelled.',
          metadata: {'booking_id': bookingId},
        );
      }

      // Reload bookings to reflect the status change
      await _loadBookings();

      // Show success or error message
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error_outline,
                color: Colors.white,
              ),
              SizedBox(width: 16),
              Expanded(child: Text(result)),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 16),
              Expanded(child: Text('Failed to cancel booking: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _bookAgain(int? routeId) async {
    if (routeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route information not available')),
      );
      return;
    }

    try {
      // Fetch the route details
      final routeData = await Routes.FetchData();
      final route = routeData
          .map((json) => Routes.fromJson(json))
          .firstWhere(
            (r) => r.id == routeId,
            orElse: () => throw Exception('Route not found'),
          );

      if (!mounted) return;

      // Navigate to route detail page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RouteDetailPage(route: route)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load route: $e')));
    }
  }

  Future<void> _goToPayment(Map<String, dynamic> booking) async {
    // TODO: Navigate to payment page with booking details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment page - Coming soon! Booking ID: ${booking['booking_id']}',
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    IconData icon,
    String label,
    String value,
    bool isDark,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          statusColor.red,
          statusColor.green,
          statusColor.blue,
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromRGBO(
            statusColor.red,
            statusColor.green,
            statusColor.blue,
            0.5,
          ),
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatClassName(String className) {
    switch (className.toLowerCase()) {
      case 'first class':
        return 'First Class';
      case 'business':
        return 'Business Class';
      case 'economy':
        return 'Economy Class';
      default:
        return className;
    }
  }

  Color _getClassColor(String className) {
    switch (className.toLowerCase()) {
      case 'first class':
        return Colors.amber;
      case 'business':
        return Colors.blue;
      case 'economy':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildClassBadge(String seatClass, ThemeData theme) {
    final classColor = _getClassColor(seatClass);
    final className = _formatClassName(seatClass);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          classColor.red,
          classColor.green,
          classColor.blue,
          0.15,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color.fromRGBO(
            classColor.red,
            classColor.green,
            classColor.blue,
            0.5,
          ),
          width: 1.5,
        ),
      ),
      child: Text(
        className,
        style: TextStyle(
          color: Color.fromRGBO(
            classColor.red,
            classColor.green,
            classColor.blue,
            0.9,
          ),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
