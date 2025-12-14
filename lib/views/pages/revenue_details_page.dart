import 'package:flutter/material.dart';
import 'package:flutter_template/models/revenue_model.dart';
import 'package:intl/intl.dart';

class RevenueDetailsPage extends StatefulWidget {
  const RevenueDetailsPage({super.key});

  @override
  State<RevenueDetailsPage> createState() => _RevenueDetailsPageState();
}

class _RevenueDetailsPageState extends State<RevenueDetailsPage> {
  List<RevenueInfo> _revenueData = [];
  List<RevenueInfo> _filteredData = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'Confirmed';
  int? _selectedYear;
  int? _selectedMonth;
  List<int> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  void _calculateAvailableYears() {
    final years = _revenueData.map((r) => r.bookingDate.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first
    _availableYears = years;
  }

  Future<void> _loadRevenueData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await RevenueInfo.fetchAllRevenue();
      if (mounted) {
        setState(() {
          _revenueData = data;
          _calculateAvailableYears();
          _filterData();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading revenue data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterData() {
    setState(() {
      _filteredData = _revenueData.where((revenue) {
        final matchesSearch =
            revenue.customerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            revenue.customerEmail.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            revenue.bookingId.toString().contains(_searchQuery);

        final matchesStatus =
            revenue.bookingStatus.toLowerCase() == _statusFilter.toLowerCase();

        final matchesYear =
            _selectedYear == null || revenue.bookingDate.year == _selectedYear;

        final matchesMonth =
            _selectedMonth == null ||
            revenue.bookingDate.month == _selectedMonth;

        return matchesSearch && matchesStatus && matchesYear && matchesMonth;
      }).toList();

      // Sort by booking date (most recent first)
      _filteredData.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    });
  }

  double _getTotalRevenue() {
    if (_statusFilter == 'Confirmed') {
      return _filteredData
          .where((r) => r.bookingStatus.toLowerCase() == 'confirmed')
          .fold(0.0, (sum, item) => sum + item.paidAmount);
    } else if (_statusFilter == 'Cancelled') {
      return _filteredData
          .where((r) => r.bookingStatus.toLowerCase() == 'cancelled')
          .fold(0.0, (sum, item) => sum + item.paidAmount);
    }
    return 0.0;
  }

  Color _getRevenueColor() {
    if (_statusFilter == 'Confirmed') {
      return Colors.green;
    } else if (_statusFilter == 'Cancelled') {
      return Colors.red;
    }
    return Colors.white;
  }

  String _getRevenueLabel() {
    if (_statusFilter == 'Confirmed') {
      return 'Revenue Gained';
    } else if (_statusFilter == 'Cancelled') {
      return 'Revenue Lost';
    }
    return 'Revenue';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text('Revenue Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRevenueData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Summary Cards
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Column(
                      children: [
                        // Total Revenue Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.trending_up,
                                    color: Colors.white70,
                                    size: 28,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                _getRevenueLabel(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                NumberFormat.currency(
                                  symbol: 'PKR ',
                                  decimalDigits: 0,
                                ).format(_getTotalRevenue()),
                                style: TextStyle(
                                  color: _getRevenueColor(),
                                  fontSize: isSmallScreen ? 28 : 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'From ${_filteredData.where((r) => r.bookingStatus.toLowerCase() == 'confirmed').length} confirmed bookings',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Statistics Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                theme: theme,
                                isDark: isDark,
                                isSmallScreen: isSmallScreen,
                                title: 'Total Bookings',
                                value: _filteredData.length.toString(),
                                icon: Icons.confirmation_number,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                theme: theme,
                                isDark: isDark,
                                isSmallScreen: isSmallScreen,
                                title: 'Confirmed',
                                value: _filteredData
                                    .where(
                                      (r) =>
                                          r.bookingStatus.toLowerCase() ==
                                          'confirmed',
                                    )
                                    .length
                                    .toString(),
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                theme: theme,
                                isDark: isDark,
                                isSmallScreen: isSmallScreen,
                                title: 'Cancelled',
                                value: _filteredData
                                    .where(
                                      (r) =>
                                          r.bookingStatus.toLowerCase() ==
                                          'cancelled',
                                    )
                                    .length
                                    .toString(),
                                icon: Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Filters
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by name, email, or booking ID...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _filterData();
                          },
                        ),
                        SizedBox(height: 12),

                        // Status Filter
                        Row(
                          children: [
                            Expanded(child: _buildFilterButton('Confirmed')),
                            SizedBox(width: 12),
                            Expanded(child: _buildFilterButton('Cancelled')),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Year and Month Filter
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Year',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value: _selectedYear,
                                items: [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('All Years'),
                                  ),
                                  ..._availableYears.map((year) {
                                    return DropdownMenuItem<int>(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                    if (value == null) {
                                      _selectedMonth = null;
                                    }
                                    _filterData();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Month',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value: _selectedMonth,
                                items: [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('All Months'),
                                  ),
                                  ...List.generate(12, (index) {
                                    final month = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: month,
                                      child: Text(
                                        DateFormat.MMMM().format(
                                          DateTime(2024, month),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: _selectedYear == null
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedMonth = value;
                                          _filterData();
                                        });
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Revenue List
                  _filteredData.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(80),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No revenue data found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _selectedMonth != null
                      ? _buildGroupedByDayList(theme, isDark, isSmallScreen)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          itemCount: _filteredData.length,
                          itemBuilder: (context, index) {
                            final revenue = _filteredData[index];
                            return _buildRevenueCard(
                              revenue,
                              theme,
                              isDark,
                              isSmallScreen,
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required bool isDark,
    required bool isSmallScreen,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final theme = Theme.of(context);
    final isSelected = _statusFilter == label;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _statusFilter = label;
          _filterData();
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        foregroundColor: isSelected
            ? theme.colorScheme.primary
            : theme.textTheme.bodyLarge?.color,
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGroupedByDayList(
    ThemeData theme,
    bool isDark,
    bool isSmallScreen,
  ) {
    // Group bookings by day
    Map<String, List<RevenueInfo>> groupedByDay = {};

    for (var revenue in _filteredData) {
      final dayKey = DateFormat('yyyy-MM-dd').format(revenue.bookingDate);
      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(revenue);
    }

    // Sort days (most recent first)
    final sortedDays = groupedByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final dayKey = sortedDays[index];
        final bookings = groupedByDay[dayKey]!;
        final date = DateTime.parse(dayKey);
        final dayRevenue = bookings.fold<double>(
          0.0,
          (sum, item) => sum + item.paidAmount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Container(
              margin: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 8),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: isSmallScreen
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat('EEE, MMM d, yyyy').format(date),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${bookings.length} booking${bookings.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                symbol: 'PKR ',
                                decimalDigits: 0,
                              ).format(dayRevenue),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _statusFilter == 'Confirmed'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${bookings.length} booking${bookings.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          NumberFormat.currency(
                            symbol: 'PKR ',
                            decimalDigits: 0,
                          ).format(dayRevenue),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _statusFilter == 'Confirmed'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
            ),
            // Bookings for this day
            ...bookings.map(
              (revenue) =>
                  _buildRevenueCard(revenue, theme, isDark, isSmallScreen),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueCard(
    RevenueInfo revenue,
    ThemeData theme,
    bool isDark,
    bool isSmallScreen,
  ) {
    Color statusColor;
    switch (revenue.bookingStatus.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #${revenue.bookingId}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(revenue.bookingDate),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    revenue.bookingStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            Divider(height: 1),
            SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: isSmallScreen ? 18 : 20,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        revenue.customerName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        revenue.customerEmail,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: isSmallScreen ? 10 : 12,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            revenue.customerPhone,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Route and Travel Details
            if (revenue.routeOrigin != null && revenue.routeDestination != null)
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.route,
                          size: isSmallScreen ? 16 : 18,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            revenue.getRouteDisplay(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (revenue.travelDate != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(revenue.travelDate!),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (revenue.travelTime != null) ...[
                            SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: isSmallScreen ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6),
                            Text(
                              revenue.travelTime!,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            if (revenue.routeOrigin != null && revenue.routeDestination != null)
              SizedBox(height: 12),

            // Ticket Details
            Row(
              children: [
                if (revenue.seatNumber != null)
                  Expanded(
                    child: _buildDetailRow(
                      icon: Icons.event_seat,
                      label: 'Seat',
                      value: revenue.seatNumber.toString(),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                if (revenue.seatNumber != null && revenue.ticketClass != null)
                  SizedBox(width: 12),
                if (revenue.ticketClass != null)
                  Expanded(
                    child: _buildDetailRow(
                      icon: Icons.class_,
                      label: 'Class',
                      value: revenue.ticketClass!,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
              ],
            ),

            // Discount and Payment Details
            if (revenue.discountCode != null || revenue.cardNumber != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  if (revenue.discountCode != null)
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.discount,
                        label: 'Discount',
                        value: revenue.discountCode!,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  if (revenue.discountCode != null &&
                      revenue.cardNumber != null)
                    SizedBox(width: 12),
                  if (revenue.cardNumber != null)
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.credit_card,
                        label: 'Card',
                        value: revenue.getMaskedCardNumber(),
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                ],
              ),
            ],

            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      revenue.bookingStatus.toLowerCase() == 'confirmed'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: revenue.bookingStatus.toLowerCase() == 'confirmed'
                          ? Colors.green
                          : Colors.red,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Paid Amount',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  NumberFormat.currency(
                    symbol: 'PKR ',
                    decimalDigits: 0,
                  ).format(revenue.paidAmount),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: revenue.bookingStatus.toLowerCase() == 'confirmed'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Icon(icon, size: isSmallScreen ? 16 : 18, color: Colors.grey[600]),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
