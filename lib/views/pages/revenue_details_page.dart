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
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
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
          _filteredData = data;
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
            _statusFilter == 'All' ||
            revenue.bookingStatus.toLowerCase() == _statusFilter.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  int _getTotalRevenue() {
    if (_statusFilter == 'Confirmed') {
      return _filteredData
          .where((r) => r.bookingStatus.toLowerCase() == 'confirmed')
          .fold(0, (sum, item) => sum + item.paidAmount);
    } else if (_statusFilter == 'Cancelled') {
      return _filteredData
          .where((r) => r.bookingStatus.toLowerCase() == 'cancelled')
          .fold(0, (sum, item) => sum + item.paidAmount);
    } else {
      // All bookings
      return _filteredData.fold(0, (sum, item) => sum + item.paidAmount);
    }
  }

  Color _getRevenueColor() {
    if (_statusFilter == 'Confirmed') {
      return Colors.green;
    } else if (_statusFilter == 'Cancelled') {
      return Colors.red;
    } else {
      return Colors.white;
    }
  }

  String _getRevenueLabel() {
    if (_statusFilter == 'Confirmed') {
      return 'Revenue Gained';
    } else if (_statusFilter == 'Cancelled') {
      return 'Revenue Lost';
    } else {
      return 'Total Revenue';
    }
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All'),
                              SizedBox(width: 8),
                              _buildFilterChip('Confirmed'),
                              SizedBox(width: 8),
                              _buildFilterChip('Cancelled'),
                            ],
                          ),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _statusFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = label;
          _filterData();
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
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

            // Ticket Details
            if (isSmallScreen)
              Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.route,
                    label: 'Route ID',
                    value: revenue.routeId.toString(),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: 8),
                  if (revenue.ticketId != null)
                    _buildDetailRow(
                      icon: Icons.confirmation_number,
                      label: 'Ticket ID',
                      value: revenue.ticketId.toString(),
                      isSmallScreen: isSmallScreen,
                    ),
                  if (revenue.ticketId != null) SizedBox(height: 8),
                  if (revenue.seatNumber != null)
                    _buildDetailRow(
                      icon: Icons.event_seat,
                      label: 'Seat',
                      value: revenue.seatNumber.toString(),
                      isSmallScreen: isSmallScreen,
                    ),
                  if (revenue.seatNumber != null) SizedBox(height: 8),
                  if (revenue.ticketClass != null)
                    _buildDetailRow(
                      icon: Icons.class_,
                      label: 'Class',
                      value: revenue.ticketClass!,
                      isSmallScreen: isSmallScreen,
                    ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(
                      icon: Icons.route,
                      label: 'Route ID',
                      value: revenue.routeId.toString(),
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: 12),
                  if (revenue.ticketId != null)
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.confirmation_number,
                        label: 'Ticket ID',
                        value: revenue.ticketId.toString(),
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  if (revenue.ticketId != null) SizedBox(width: 12),
                  if (revenue.seatNumber != null)
                    Expanded(
                      child: _buildDetailRow(
                        icon: Icons.event_seat,
                        label: 'Seat',
                        value: revenue.seatNumber.toString(),
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  if (revenue.seatNumber != null) SizedBox(width: 12),
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
