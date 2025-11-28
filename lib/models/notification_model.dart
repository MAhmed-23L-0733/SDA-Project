import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

enum NotificationType { booking, cancellation, payment, upcomingTrip }

class AppNotification {
  final String id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      userId: json['user_id'],
      type: _parseNotificationType(json['type']),
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
      metadata: json['metadata'],
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'cancellation':
        return NotificationType.cancellation;
      case 'payment':
        return NotificationType.payment;
      case 'upcoming_trip':
        return NotificationType.upcomingTrip;
      default:
        return NotificationType.booking;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }
}

class NotificationService {
  // Get upcoming confirmed bookings (first 3)
  static Future<List<Map<String, dynamic>>> getUpcomingBookings(
    int userId,
  ) async {
    try {
      final response = await supabase.rpc(
        'get_user_history',
        params: {'p_user_id': userId},
      );

      if (response == null) return [];

      final bookings = List<Map<String, dynamic>>.from(response as List);

      print('DEBUG: Total bookings fetched: ${bookings.length}');
      if (bookings.isNotEmpty) {
        print('DEBUG: First booking keys: ${bookings.first.keys.toList()}');
        print('DEBUG: First booking data: ${bookings.first}');
      }

      // Filter confirmed bookings that are in the future
      final now = DateTime.now();
      final upcoming = bookings.where((booking) {
        // Use 'status' field from database
        final status = (booking['status'] ?? '').toString().toLowerCase();

        print('DEBUG: Booking status: $status');

        if (status != 'confirmed') return false;

        try {
          // Use 'travel_date' field from database
          final travelDateStr = booking['travel_date'];
          if (travelDateStr == null) return false;

          final travelDate = DateTime.parse(travelDateStr);
          print('DEBUG: Travel date: $travelDate, Now: $now');
          return travelDate.isAfter(now);
        } catch (e) {
          print('DEBUG: Error parsing date: $e');
          return false;
        }
      }).toList();

      print('DEBUG: Filtered upcoming bookings: ${upcoming.length}');

      // Sort by travel date (earliest first)
      upcoming.sort((a, b) {
        final dateA = DateTime.parse(a['travel_date']);
        final dateB = DateTime.parse(b['travel_date']);
        return dateA.compareTo(dateB);
      });

      // Return first 3
      return upcoming.take(3).toList();
    } catch (e) {
      print('Error fetching upcoming bookings: $e');
      return [];
    }
  }

  // Create a notification for user action
  static Future<void> createActionNotification({
    required int userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _addToLocalNotifications(
        userId: userId,
        type: type,
        title: title,
        message: message,
        metadata: metadata,
      );
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Local storage for action notifications (in-memory for now)
  static final Map<int, List<AppNotification>> _userNotifications = {};

  static Future<void> _addToLocalNotifications({
    required int userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_userNotifications.containsKey(userId)) {
      _userNotifications[userId] = [];
    }

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _userNotifications[userId]!.insert(0, notification);
  }

  // Get all action notifications for a user
  static List<AppNotification> getActionNotifications(int userId) {
    return _userNotifications[userId] ?? [];
  }

  // Clear all notifications for a user
  static void clearNotifications(int userId) {
    _userNotifications[userId]?.clear();
  }

  // Mark notification as read
  static void markAsRead(int userId, String notificationId) {
    final notifications = _userNotifications[userId];
    if (notifications != null) {
      final index = notifications.indexWhere(
        (notif) => notif.id == notificationId,
      );
      if (index != -1) {
        final notif = notifications[index];
        notifications[index] = AppNotification(
          id: notif.id,
          userId: notif.userId,
          type: notif.type,
          title: notif.title,
          message: notif.message,
          timestamp: notif.timestamp,
          isRead: true,
          metadata: notif.metadata,
        );
      }
    }
  }

  // Get unread count
  static int getUnreadCount(int userId) {
    final notifications = _userNotifications[userId];
    if (notifications == null) return 0;
    return notifications.where((notif) => !notif.isRead).length;
  }
}
