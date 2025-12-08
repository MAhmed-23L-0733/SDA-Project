import 'package:flutter/material.dart';
import 'package:flutter_template/data/notifiers.dart';
import 'package:flutter_template/models/admin_model.dart';
import 'package:flutter_template/models/customer_model.dart';
import 'package:flutter_template/models/notification_model.dart';
import 'package:flutter_template/views/pages/hero_page.dart';
import 'package:flutter_template/views/pages/home_page.dart';
import 'package:flutter_template/views/pages/manage_routes_page.dart';
import 'package:flutter_template/views/pages/my_bookings_page.dart';
import 'package:flutter_template/views/pages/dashboard_page.dart';
import 'package:flutter_template/views/pages/manage_discounts_page.dart';
import 'package:flutter_template/views/pages/profile_page.dart';
import 'package:flutter_template/widgets/navbar_widget.dart';
import 'package:flutter_template/widgets/notification_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

List<Widget> customerPages = [HomePage(), MyBookingsPage(), ProfilePage()];
List<Widget> adminPages = [
  DashboardPage(),
  ManageRoutesPage(),
  ManageDiscountsPage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  static Color _getRandomAvatarColor(String initial) {
    final colors = [
      Color(0xFF7C4DFF), // Purple
      Color(0xFFE91E63), // Pink
      Color(0xFF2196F3), // Blue
      Color(0xFF00BCD4), // Cyan
      Color(0xFF009688), // Teal
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFFFF5722), // Deep Orange
      Color(0xFF9C27B0), // Deep Purple
      Color(0xFF3F51B5), // Indigo
    ];

    // Use the character code of the initial to pick a consistent color
    int index = initial.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BookFlee",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: isSmallScreen ? 6 : 10,
          ),
        ),
        centerTitle: true,
        actionsPadding: EdgeInsets.only(right: 10, left: 10),
        actions: [
          IconButton(
            onPressed: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                if (isDarkMode) {
                  return Icon(
                    Icons.dark_mode,
                    color: theme.colorScheme.primary,
                  );
                } else {
                  return Icon(
                    Icons.light_mode,
                    color: theme.colorScheme.primary,
                  );
                }
              },
            ),
            iconSize: 30,
          ),
          ValueListenableBuilder(
            valueListenable: isSignedInNotifier,
            builder: (context, isSignedIn, child) {
              return isSignedIn && roleNotifier.value == "customer"
                  ? PopupMenuButton<void>(
                      offset: Offset(
                        isSmallScreen
                            ? -MediaQuery.of(context).size.width + 60
                            : 0,
                        50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: isSmallScreen
                          ? BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,
                              maxWidth: MediaQuery.of(context).size.width,
                            )
                          : null,
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<void>(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: NotificationMenu(
                            userId: customerNotifier.value.id!,
                          ),
                        ),
                      ],
                      icon: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 30,
                            color: theme.colorScheme.primary,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: ValueListenableBuilder(
                              valueListenable: customerNotifier,
                              builder: (context, customer, child) {
                                if (customer.id == null) {
                                  return SizedBox.shrink();
                                }
                                final unreadCount =
                                    NotificationService.getUnreadCount(
                                      customer.id!,
                                    );
                                if (unreadCount == 0) return SizedBox.shrink();
                                return Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
          ValueListenableBuilder(
            valueListenable: isSignedInNotifier,
            builder: (context, isSignedIn, child) {
              return isSignedIn
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: PopupMenuButton<String>(
                        offset: Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'signout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (String value) async {
                          if (value == 'signout') {
                            // Show confirmation dialog
                            final bool? confirmSignOut = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Sign Out'),
                                  content: Text(
                                    'Are you sure you want to sign out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text('Sign Out'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmSignOut == true) {
                              try {
                                // Clear notifications before resetting user data
                                final userId = customerNotifier.value.id;
                                if (userId != null) {
                                  NotificationService.clearNotifications(
                                    userId,
                                  );
                                }

                                // Reset all notifiers
                                isSignedInNotifier.value = false;
                                roleNotifier.value = "guest";

                                selectedPageNotifier.value = 0;
                                customerNotifier.value = Customer(
                                  id: null,
                                  firstName: '',
                                  lastName: '',
                                  email: '',
                                  phone: '',
                                  dob: DateTime.now(),
                                  gender: -1,
                                );
                                adminNotifier.value = Admin(
                                  id: null,
                                  firstName: '',
                                  lastName: '',
                                  email: '',
                                  phone: '',
                                  dob: DateTime.now(),
                                  gender: -1,
                                );

                                // Show success message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12),
                                          Text('Successfully signed out'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Show error message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12),
                                          Text('Error signing out: $e'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 2.5),
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: roleNotifier,
                            builder: (context, role, child) {
                              final lastName = role == "customer"
                                  ? customerNotifier.value.lastName
                                  : adminNotifier.value.lastName;
                              return Container(
                                decoration: BoxDecoration(
                                  color: _getRandomAvatarColor(
                                    lastName?[0] ?? 'U',
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    (lastName?[0] ?? 'U').toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: isSignedInNotifier,
        builder: (context, isSignedIn, child) {
          return isSignedIn ? NavbarWidget() : SizedBox.shrink();
        },
      ),
      body: ValueListenableBuilder(
        valueListenable: isSignedInNotifier,
        builder: (context, isSignedIn, child) {
          if (!isSignedIn) return HeroPage();

          return ValueListenableBuilder(
            valueListenable: roleNotifier,
            builder: (context, role, child) {
              return ValueListenableBuilder(
                valueListenable: selectedPageNotifier,
                builder: (context, selectedPage, child) {
                  if (role == "admin") {
                    // Ensure selectedPage is within admin pages range
                    final safeIndex = selectedPage >= adminPages.length
                        ? 0
                        : selectedPage;
                    return adminPages.elementAt(safeIndex);
                  } else {
                    // Ensure selectedPage is within customer pages range
                    final safeIndex = selectedPage >= customerPages.length
                        ? 0
                        : selectedPage;
                    return customerPages.elementAt(safeIndex);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
