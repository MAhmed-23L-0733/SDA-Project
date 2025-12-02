import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_template/data/notifiers.dart';
import 'package:flutter_template/models/bookings_model.dart';
import 'package:flutter_template/models/notification_model.dart';
import 'package:flutter_template/models/routes_model.dart' hide supabase;
import 'package:flutter_template/models/ticket_model.dart';
import 'package:flutter_template/models/discount_model.dart';
import 'package:flutter_template/models/payment_model.dart';

class RouteDetailPage extends StatefulWidget {
  final Routes route;

  const RouteDetailPage({super.key, required this.route});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedSeats = 1;
  List<Ticket> _tickets = [];
  final Set<int> _selectedSeatNumbers = {};
  bool _loadingTickets = true;
  bool _booking = false;

  // Discount related
  final _discountController = TextEditingController();
  int? _discountValue;
  bool _applyingDiscount = false;
  String? _discountError;
  final Set<int> _ticketsWithAppliedDiscount = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadTickets();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  String _formatTime(String time) {
    String supabaseTimeString = time;
    List<String> parts = supabaseTimeString.split(":");
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    String formattedTime = timeOfDay.format(context);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1474487548417-781cb71495f3?q=80&w=2000',
            ),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a0033),
                    const Color(0xFF2d1b4e),
                    const Color(0xFF3d2667),
                  ]
                : [
                    const Color(0xFF4a148c),
                    const Color(0xFF38006b),
                    const Color(0xFF2d004e),
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: _handleBackNavigation,
                ),
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: const EdgeInsets.only(
                          left: 60,
                          bottom: 16,
                        ),
                        title: FadeTransition(
                          opacity: _animationController,
                          child: Text(
                            'Route Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Route Card
                        _buildRouteCard(isDark),
                        const SizedBox(height: 24),

                        // Journey Info
                        _buildJourneyInfo(isDark),
                        const SizedBox(height: 24),

                        // Seats Selection
                        _buildSeatsSelection(isDark),
                        const SizedBox(height: 24),

                        // Pricing
                        _buildPricing(isDark),
                        const SizedBox(height: 32),

                        // Book Now Button
                        _buildBookButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Origin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.route.origin ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.train, color: Colors.white, size: 32),
                  ),

                  // Destination
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'To',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.route.destination ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.route.date != null
                        ? '${widget.route.date!.day}/${widget.route.date!.month}/${widget.route.date!.year}'
                        : 'No date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.route.time != null
                        ? _formatTime(widget.route.time!)
                        : 'No time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _caulculateAvailableTickets() {
    Ticket ticket;
    int count = _tickets.length;
    for (ticket in _tickets) {
      if (ticket.status == 2) {
        count--;
      }
    }
    return count;
  }

  Widget _buildJourneyInfo(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journey Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.event_seat,
                'Available Seats',
                _caulculateAvailableTickets().toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ),
        _loadingTickets
            ? SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(color: Colors.grey),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ],
    );
  }

  Widget _buildSeatsSelection(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Seats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Seat grid / map - Train Layout by Class
              _loadingTickets
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    )
                  : _tickets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'No seats available for this route.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  : _buildAllTrainsLayout(),
              const SizedBox(height: 12),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _legendItem(Colors.white.withOpacity(0.12), 'Available'),
                  _legendItem(const Color(0xFF7C4DFF), 'Selected'),
                  _legendItem(
                    Colors.red.withOpacity(0.7),
                    'Sold',
                    icon: Icons.lock,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, {IconData? icon}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: icon != null
              ? Icon(icon, size: 14, color: Colors.white70)
              : null,
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildAllTrainsLayout() {
    // Separate tickets by class
    final firstClassTickets =
        _tickets.where((t) => t.Class?.toLowerCase() == 'first class').toList()
          ..sort((a, b) => (a.seatNumber ?? 0).compareTo(b.seatNumber ?? 0));

    final businessClassTickets =
        _tickets.where((t) => t.Class?.toLowerCase() == 'business').toList()
          ..sort((a, b) => (a.seatNumber ?? 0).compareTo(b.seatNumber ?? 0));

    final economyClassTickets =
        _tickets.where((t) => t.Class?.toLowerCase() == 'economy').toList()
          ..sort((a, b) => (a.seatNumber ?? 0).compareTo(b.seatNumber ?? 0));

    return Column(
      children: [
        if (firstClassTickets.isNotEmpty) ...[
          _buildTrainLayout(
            tickets: firstClassTickets,
            className: 'FIRST CLASS',
            primaryColor: Colors.amber,
            secondaryColor: Colors.orange,
            icon: Icons.diamond,
          ),
          SizedBox(height: 20),
        ],
        if (businessClassTickets.isNotEmpty) ...[
          _buildTrainLayout(
            tickets: businessClassTickets,
            className: 'BUSINESS',
            primaryColor: Colors.blue,
            secondaryColor: Colors.indigo,
            icon: Icons.business_center,
          ),
          SizedBox(height: 20),
        ],
        if (economyClassTickets.isNotEmpty) ...[
          _buildTrainLayout(
            tickets: economyClassTickets,
            className: 'ECONOMY',
            primaryColor: Colors.green,
            secondaryColor: Colors.teal,
            icon: Icons.airline_seat_recline_normal,
          ),
        ],
      ],
    );
  }

  Widget _buildTrainLayout({
    required List<Ticket> tickets,
    required String className,
    required Color primaryColor,
    required Color secondaryColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          // Train Front with Class Label
          Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.4),
                  secondaryColor.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: primaryColor.withOpacity(0.4)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    className,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          // Seats in rows with aisle
          ...List.generate((tickets.length / 4).ceil(), (rowIndex) {
            final startIndex = rowIndex * 4;
            final rowSeats = tickets.skip(startIndex).take(4).toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Left side seats (2 seats)
                  ...rowSeats
                      .take(2)
                      .map(
                        (ticket) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildTrainSeat(ticket, primaryColor),
                          ),
                        ),
                      ),

                  // Aisle
                  SizedBox(
                    width: 30,
                    height: 60,
                    child: Center(
                      child: Container(
                        width: 2,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              primaryColor.withOpacity(0.1),
                              primaryColor.withOpacity(0.3),
                              primaryColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right side seats (2 seats)
                  ...rowSeats
                      .skip(2)
                      .take(2)
                      .map(
                        (ticket) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildTrainSeat(ticket, primaryColor),
                          ),
                        ),
                      ),
                ],
              ),
            );
          }),

          SizedBox(height: 12),
          // Train Back
          Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: primaryColor.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                'BACK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainSeat(Ticket ticket, Color classColor) {
    final seatNum = ticket.seatNumber ?? 0;
    final isSold = (ticket.status ?? 0) == 2;
    final isSelected = _selectedSeatNumbers.contains(seatNum);

    return Material(
      color: isSold
          ? Colors.red.withOpacity(0.6)
          : isSelected
          ? const Color(0xFF7C4DFF)
          : classColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      elevation: isSelected ? 4 : 0,
      child: InkWell(
        onTap: isSold ? null : () => _onSeatTap(seatNum),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSold ? Icons.lock : Icons.chair,
                color: isSelected || isSold ? Colors.white : Colors.white70,
                size: 18,
              ),
              SizedBox(height: 2),
              Text(
                '$seatNum',
                style: TextStyle(
                  color: isSelected || isSold ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              if (ticket.price != null)
                Text(
                  '${ticket.price!.toInt()}',
                  style: TextStyle(
                    color: isSelected || isSold ? Colors.white : Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricing(bool isDark) {
    // Calculate price from selected seats
    double totalPrice = 0;
    for (final seatNum in _selectedSeatNumbers) {
      final ticket = _tickets.firstWhere(
        (t) => t.seatNumber == seatNum,
        orElse: () => Ticket(price: 0),
      );
      totalPrice += ticket.price ?? 0;
    }
    final avgPrice = _selectedSeatNumbers.isEmpty
        ? 0
        : (totalPrice / _selectedSeatNumbers.length).toInt();

    // Calculate discounted price
    double finalPrice = totalPrice;
    double discountAmount = 0;
    if (_discountValue != null && _discountValue! > 0) {
      discountAmount = (totalPrice * _discountValue!) / 100;
      finalPrice = totalPrice - discountAmount;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg Price per Seat',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    'PKR $avgPrice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number of Seats',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    '$_selectedSeats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),

              // Discount Code Section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Discount Code',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Enter code',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.discount, color: Colors.white70),
                        errorText: _discountError,
                        errorStyle: TextStyle(color: Colors.red[300]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      enabled: !_applyingDiscount,
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _applyingDiscount ? null : _validateDiscount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: const Color(0xFF4a148c),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _applyingDiscount
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF4a148c),
                              ),
                            ),
                          )
                        : Text('Apply'),
                  ),
                ],
              ),

              if (_discountValue != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[300],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Discount applied: $_discountValue% OFF',
                        style: TextStyle(
                          color: Colors.green[300],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.green[300],
                          size: 18,
                        ),
                        onPressed: _clearDiscount,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Price breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    'PKR ${totalPrice.toInt()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      decoration: _discountValue != null
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),

              if (_discountValue != null) ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount',
                      style: TextStyle(fontSize: 16, color: Colors.green[300]),
                    ),
                    Text(
                      '- PKR ${discountAmount.toInt()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[300],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'PKR ${finalPrice.toInt()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _discountValue != null
                          ? Colors.green[300]
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _booking ? null : _bookSelectedSeats,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.9),
          foregroundColor: const Color(0xFF4a148c),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark, size: 24),
            const SizedBox(width: 12),
            Text(
              'Book Now',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loadingTickets = true;
    });
    try {
      final routeId = widget.route.id;
      if (routeId == null) {
        _tickets = [];
      } else {
        _tickets = await Ticket.fetchByRoute(routeId);
      }
    } catch (e) {
      _tickets = [];
    }
    if (!mounted) return;
    setState(() {
      _loadingTickets = false;
      _selectedSeatNumbers.clear();
    });
  }

  void _onSeatTap(int seatNumber) {
    setState(() {
      if (_selectedSeatNumbers.contains(seatNumber)) {
        _selectedSeatNumbers.remove(seatNumber);
      } else {
        _selectedSeatNumbers.add(seatNumber);
      }
      _selectedSeats = _selectedSeatNumbers.isEmpty
          ? 0
          : _selectedSeatNumbers.length;
    });
  }

  Future<void> _bookSelectedSeats() async {
    if (_selectedSeatNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one seat to book.'),
        ),
      );
      return;
    }

    final userId = customerNotifier.value.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book seats')),
      );
      return;
    }

    // Check for payment methods
    List<PaymentInfo> paymentMethods = [];
    try {
      paymentMethods = await PaymentInfo.getUserPaymentMethods(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment methods: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (paymentMethods.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Payment Method'),
            content: Text(
              'Please add a payment method in your profile page before booking tickets.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Show payment method selection dialog
    final selectedPayment = await showDialog<PaymentInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Payment Method'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: paymentMethods.map((payment) {
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    PaymentInfo.getCardType(payment.cardNumber ?? ''),
                  ),
                  subtitle: Text(payment.cardNumber ?? ''),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).pop(payment),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedPayment == null || selectedPayment.id == null) {
      return;
    }

    setState(() {
      _booking = true;
    });

    final seatList = _selectedSeatNumbers.toList();
    final results = await Bookings.bookMultipleSeats(
      userId: userId,
      routeId: widget.route.id ?? 0,
      seatNumbers: seatList,
      paymentInfoId: selectedPayment.id!,
    );

    // Analyze results
    final successes = <int>[];
    final failures = <Map<String, dynamic>>[];
    for (final r in results) {
      final seat = r['seat'] as int;
      final res = r['result'] as Map<String, dynamic>;
      if (res['booking_id'] != null) {
        successes.add(seat);
      } else {
        failures.add({
          'seat': seat,
          'msg': res['status_message'] ?? 'Unknown error',
        });
      }
    }

    if (!mounted) return;

    // Create notification for successful bookings
    if (successes.isNotEmpty && customerNotifier.value.id != null) {
      await NotificationService.createActionNotification(
        userId: customerNotifier.value.id!,
        type: NotificationType.booking,
        title: 'Booking Confirmed',
        message:
            'Successfully booked ${successes.length} seat(s): ${successes.join(", ")} for ${widget.route.origin} to ${widget.route.destination}',
        metadata: {'route_id': widget.route.id, 'seats': successes},
      );
    }

    // Clear discount tracking for successfully booked tickets
    if (successes.isNotEmpty) {
      for (final seatNum in successes) {
        final ticket = _tickets.firstWhere(
          (t) => t.seatNumber == seatNum,
          orElse: () => Ticket(),
        );
        if (ticket.id != null) {
          _ticketsWithAppliedDiscount.remove(ticket.id!);
        }
      }
    }

    // Refresh tickets
    await _loadTickets();

    setState(() {
      _booking = false;
    });

    // Show dialog summarizing results
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            successes.isNotEmpty ? 'Booking Results' : 'Booking Failed',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (successes.isNotEmpty)
                Text('Successfully booked seats: ${successes.join(', ')}'),
              if (failures.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Failed to book:'),
                ...failures.map((f) => Text('Seat ${f['seat']}: ${f['msg']}')),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _validateDiscount() async {
    final code = _discountController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _discountError = 'Please enter a discount code';
      });
      return;
    }

    if (_selectedSeatNumbers.isEmpty) {
      setState(() {
        _discountError = 'Please select seats first';
      });
      return;
    }

    setState(() {
      _applyingDiscount = true;
      _discountError = null;
    });

    try {
      final discountValue = await Discount.validateDiscountCode(code);

      // Get ticket IDs for selected seats
      final ticketIds = <int>[];
      for (final seatNum in _selectedSeatNumbers) {
        final ticket = _tickets.firstWhere(
          (t) => t.seatNumber == seatNum,
          orElse: () => Ticket(),
        );
        if (ticket.id != null) {
          ticketIds.add(ticket.id!);
        }
      }

      // Apply discount code to tickets
      if (ticketIds.isNotEmpty) {
        await Ticket.updateDiscountCodesForTickets(ticketIds, code);
        _ticketsWithAppliedDiscount.addAll(ticketIds);
      }

      if (!mounted) return;

      setState(() {
        _discountValue = discountValue;
        _discountError = null;
        _applyingDiscount = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Discount code applied: $discountValue% OFF'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _discountError = e.toString().replaceAll('Exception: ', '');
        _discountValue = null;
        _applyingDiscount = false;
      });
    }
  }

  Future<void> _clearDiscount() async {
    // Remove discount codes from tickets
    if (_ticketsWithAppliedDiscount.isNotEmpty) {
      try {
        await Ticket.updateDiscountCodesForTickets(
          _ticketsWithAppliedDiscount.toList(),
          null,
        );
        _ticketsWithAppliedDiscount.clear();
      } catch (e) {
        // Silently fail
      }
    }

    setState(() {
      _discountController.clear();
      _discountValue = null;
      _discountError = null;
    });
  }

  Future<void> _handleBackNavigation() async {
    // Clear any applied discount codes before leaving
    if (_ticketsWithAppliedDiscount.isNotEmpty) {
      try {
        await Ticket.updateDiscountCodesForTickets(
          _ticketsWithAppliedDiscount.toList(),
          null,
        );
      } catch (e) {
        // Silently fail
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
