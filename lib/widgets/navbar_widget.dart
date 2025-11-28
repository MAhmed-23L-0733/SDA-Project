import 'package:flutter/material.dart';
import 'package:flutter_template/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return ValueListenableBuilder(
          valueListenable: roleNotifier,
          builder: (context, role, child) {
            final destinations = role == "admin"
                ? [
                    NavigationDestination(
                      icon: Icon(
                        Icons.dashboard_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                      label: "Dashboard",
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.route_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.route, color: Colors.white),
                      label: "Routes",
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.discount_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.discount, color: Colors.white),
                      label: "Discounts",
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.person_outline,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.person, color: Colors.white),
                      label: "Profile",
                    ),
                  ]
                : [
                    NavigationDestination(
                      icon: Icon(
                        Icons.home_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.home, color: Colors.white),
                      label: "Home",
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.bookmark_border,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.bookmark, color: Colors.white),
                      label: "My Bookings",
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.person_outline,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      selectedIcon: Icon(Icons.person, color: Colors.white),
                      label: "Profile",
                    ),
                  ];

            return NavigationBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              indicatorColor: theme.colorScheme.primary,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: destinations,
              onDestinationSelected: (int value) {
                selectedPageNotifier.value = value;
              },
              selectedIndex: selectedPage,
            );
          },
        );
      },
    );
  }
}
