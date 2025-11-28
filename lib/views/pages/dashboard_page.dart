import 'package:flutter/material.dart';
import 'package:flutter_template/models/admin_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _metrics;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final metrics = await Admin.getAdminMetrics();
      if (!mounted) return;

      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading Dashboard...',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading metrics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadMetrics,
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMetrics,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMMM dd, yyyy',
                              ).format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _loadMetrics,
                          icon: Icon(Icons.refresh),
                          color: theme.colorScheme.primary,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Revenue Card
                    _buildRevenueCard(theme, isDark),
                    SizedBox(height: 16),

                    // Route Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            title: 'Total Routes',
                            value: _metrics!['total_routes'].toString(),
                            icon: Icons.route,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            title: 'Active Routes',
                            value: _metrics!['active_routes'].toString(),
                            icon: Icons.flight_takeoff,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Ticket Utilization Chart
                    _buildTicketUtilizationChart(theme, isDark),
                    SizedBox(height: 16),

                    // Booking Status Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            title: 'Confirmed',
                            value: _metrics!['confirmed_bookings'].toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            title: 'Cancelled',
                            value: _metrics!['cancelled_bookings'].toString(),
                            icon: Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Bookings Distribution Pie Chart
                    _buildBookingsChart(theme, isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRevenueCard(ThemeData theme, bool isDark) {
    final revenue = _metrics!['total_revenue'] as int;
    final formattedRevenue = NumberFormat.currency(
      symbol: 'PKR ',
      decimalDigits: 0,
    ).format(revenue);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            Color.fromRGBO(
              theme.colorScheme.primary.red,
              theme.colorScheme.primary.green,
              theme.colorScheme.primary.blue,
              0.7,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              theme.colorScheme.primary.red,
              theme.colorScheme.primary.green,
              theme.colorScheme.primary.blue,
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
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.attach_money, color: Colors.white, size: 28),
              ),
              Spacer(),
              Icon(
                Icons.trending_up,
                color: const Color.fromRGBO(255, 255, 255, 0.8),
                size: 32,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Total Revenue',
            style: TextStyle(
              color: const Color.fromRGBO(255, 255, 255, 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            formattedRevenue,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'From confirmed bookings',
            style: TextStyle(
              color: const Color.fromRGBO(255, 255, 255, 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketUtilizationChart(ThemeData theme, bool isDark) {
    final totalTickets = (_metrics!['total_tickets'] as int).toDouble();
    final soldTickets = (_metrics!['sold_tickets'] as int).toDouble();
    final availableTickets = totalTickets - soldTickets;

    final utilizationPercent = totalTickets > 0
        ? ((soldTickets / totalTickets) * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ticket Utilization',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    theme.colorScheme.primary.red,
                    theme.colorScheme.primary.green,
                    theme.colorScheme.primary.blue,
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$utilizationPercent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: totalTickets > 0 ? totalTickets * 1.1 : 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? Colors.grey[800]! : Colors.grey[700]!,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = groupIndex == 0 ? 'Sold' : 'Available';
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Sold',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          case 1:
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Available',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          case 2:
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          default:
                            return Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: totalTickets > 0 ? totalTickets / 5 : 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color.fromRGBO(
                        theme.dividerColor.red,
                        theme.dividerColor.green,
                        theme.dividerColor.blue,
                        0.2,
                      ),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: soldTickets,
                        color: Colors.green,
                        width: 50,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: availableTickets,
                        color: Colors.orange,
                        width: 50,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: totalTickets,
                        color: Colors.blue,
                        width: 50,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Sold', Colors.green, soldTickets.toInt()),
              _buildLegendItem(
                'Available',
                Colors.orange,
                availableTickets.toInt(),
              ),
              _buildLegendItem('Total', Colors.blue, totalTickets.toInt()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsChart(ThemeData theme, bool isDark) {
    final confirmed = (_metrics!['confirmed_bookings'] as int).toDouble();
    final cancelled = (_metrics!['cancelled_bookings'] as int).toDouble();
    final total = confirmed + cancelled;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: total > 0
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: confirmed,
                                title:
                                    '${((confirmed / total) * 100).toStringAsFixed(0)}%',
                                radius: 60,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.red,
                                value: cancelled,
                                title:
                                    '${((cancelled / total) * 100).toStringAsFixed(0)}%',
                                radius: 60,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPieLegendItem(
                              'Confirmed',
                              Colors.green,
                              confirmed.toInt(),
                            ),
                            SizedBox(height: 16),
                            _buildPieLegendItem(
                              'Cancelled',
                              Colors.red,
                              cancelled.toInt(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'No bookings yet',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
