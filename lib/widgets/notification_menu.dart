import 'package:flutter/material.dart';
import 'package:flutter_template/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationMenu extends StatefulWidget {
  final int userId;

  const NotificationMenu({super.key, required this.userId});

  @override
  State<NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<AppNotification> _actionNotifications = [];
  bool _isLoading = true;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final upcoming = await NotificationService.getUpcomingBookings(
        widget.userId,
      );
      final actions = NotificationService.getActionNotifications(widget.userId);

      if (mounted) {
        setState(() {
          _upcomingBookings = upcoming;
          _actionNotifications = actions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActions = _actionNotifications.isNotEmpty;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isSmallScreen ? MediaQuery.of(context).size.width : 380,
      constraints: BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showUpcoming = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _showUpcoming
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Upcoming Trips',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: _showUpcoming
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _showUpcoming
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasActions)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _showUpcoming = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !_showUpcoming
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Recent Actions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: !_showUpcoming
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: !_showUpcoming
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            if (_actionNotifications.any((n) => !n.isRead)) ...[
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${NotificationService.getUnreadCount(widget.userId)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: _isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _showUpcoming
                ? _buildUpcomingTrips()
                : _buildRecentActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTrips() {
    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        message: 'No upcoming trips',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = _upcomingBookings[index];
        return _buildUpcomingBookingCard(booking);
      },
    );
  }

  Widget _buildRecentActions() {
    if (_actionNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        message: 'No recent actions',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _actionNotifications.length,
      itemBuilder: (context, index) {
        final notification = _actionNotifications[index];
        return _buildActionNotificationCard(notification);
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Color.fromRGBO(
                theme.colorScheme.primary.red,
                theme.colorScheme.primary.green,
                theme.colorScheme.primary.blue,
                0.3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: (theme.textTheme.bodyMedium?.color)?.withValues(
                  alpha: 0.6,
                ),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBookingCard(Map<String, dynamic> booking) {
    final theme = Theme.of(context);
    final travelDate = DateTime.parse(booking['travel_date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(travelDate);
    final formattedTime = DateFormat('h:mm a').format(travelDate);
    final route = booking['route'] ?? 'Unknown Route';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          theme.colorScheme.primary.red,
          theme.colorScheme.primary.green,
          theme.colorScheme.primary.blue,
          0.05,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color.fromRGBO(
            theme.colorScheme.primary.red,
            theme.colorScheme.primary.green,
            theme.colorScheme.primary.blue,
            0.2,
          ),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.train, size: 20, color: theme.colorScheme.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  route,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                formattedTime,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.airline_seat_recline_normal,
                size: 14,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6),
              Text(
                'Seat ${booking['seat_number']} • ${booking['class'] ?? 'Standard'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionNotificationCard(AppNotification notification) {
    final theme = Theme.of(context);
    final formattedTime = _formatTimestamp(notification.timestamp);

    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.booking:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.cancellation:
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case NotificationType.payment:
        icon = Icons.payment;
        iconColor = Colors.blue;
        break;
      case NotificationType.upcomingTrip:
        icon = Icons.schedule;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? theme.cardColor
            : Color.fromRGBO(
                theme.colorScheme.primary.red,
                theme.colorScheme.primary.green,
                theme.colorScheme.primary.blue,
                0.05,
              ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isRead
              ? theme.dividerColor
              : Color.fromRGBO(
                  theme.colorScheme.primary.red,
                  theme.colorScheme.primary.green,
                  theme.colorScheme.primary.blue,
                  0.2,
                ),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                iconColor.red,
                iconColor.green,
                iconColor.blue,
                0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: (theme.textTheme.bodyMedium?.color)?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: (theme.textTheme.bodyMedium?.color)?.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }
}
