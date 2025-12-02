import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_template/models/routes_model.dart';
import 'package:flutter_template/views/pages/route_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _selectedDate;
  List<Routes> _routes = [];
  List<Routes> _allRoutes = []; // Store all routes for filtering
  bool _isSearching = false;
  bool _isLoading = true; // Add loading state
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Load sample routes
    _loadSampleRoutes();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadSampleRoutes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> data = await Routes.FetchData();
      if (!mounted) return;

      setState(() {
        _allRoutes = data.map((json) => Routes.fromJson(json)).toList();
        _routes = List.from(_allRoutes); // Initialize displayed routes
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching routes: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF0f3460),
              onPrimary: Colors.white,
              surface: const Color(0xFF16213e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _searchRoutes() {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    // Simulate search with delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        _isSearching = false;

        // If all search fields are empty, show all routes
        if (_originController.text.isEmpty &&
            _destinationController.text.isEmpty &&
            _selectedDate == null) {
          _routes = List.from(_allRoutes);
        } else {
          // Filter from all routes based on search criteria
          _routes = _allRoutes.where((route) {
            bool matchesOrigin =
                _originController.text.isEmpty ||
                route.origin!.toLowerCase().contains(
                  _originController.text.toLowerCase(),
                );
            bool matchesDestination =
                _destinationController.text.isEmpty ||
                route.destination!.toLowerCase().contains(
                  _destinationController.text.toLowerCase(),
                );
            bool matchesDate =
                _selectedDate == null ||
                (route.date != null &&
                    route.date!.year == _selectedDate!.year &&
                    route.date!.month == _selectedDate!.month &&
                    route.date!.day == _selectedDate!.day);
            return matchesOrigin && matchesDestination && matchesDate;
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        height: double.infinity,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Search Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildSearchCard(isDark),
                    ),
                  ),
                ),
              ),

              // Routes List Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.route,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Available Routes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Routes List
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.purple),
                          const SizedBox(height: 16),
                          Text(
                            'Loading routes...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_isSearching)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                  ),
                )
              else if (_routes.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No routes found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _buildRouteCard(_routes[index], isDark),
                      );
                    }, childCount: _routes.length),
                  ),
                ),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(bool isDark) {
    return Card(
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.search, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Your Journey',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find the perfect train route',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Origin Field
            _buildGlassTextField(
              controller: _originController,
              label: 'Origin',
              icon: Icons.my_location,
              hint: 'Enter departure city',
            ),
            const SizedBox(height: 16),

            // Destination Field
            _buildGlassTextField(
              controller: _destinationController,
              label: 'Destination',
              icon: Icons.location_on,
              hint: 'Enter arrival city',
            ),
            const SizedBox(height: 16),

            // Date Field
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedDate == null
                              ? (isDark ? Colors.white60 : Colors.black45)
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Button
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _searchRoutes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 26),
                    const SizedBox(width: 12),
                    Text(
                      'Search Routes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.fromRGBO(
            theme.colorScheme.primary.red,
            theme.colorScheme.primary.green,
            theme.colorScheme.primary.blue,
            0.3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
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
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: label,
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildRouteCard(Routes route, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailPage(route: route),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    // Origin
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            theme.colorScheme.primary.red,
                            theme.colorScheme.primary.green,
                            theme.colorScheme.primary.blue,
                            0.05,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color.fromRGBO(
                              theme.colorScheme.primary.red,
                              theme.colorScheme.primary.green,
                              theme.colorScheme.primary.blue,
                              0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.greenAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              route.origin ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Train icon
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(
                              theme.colorScheme.primary.red,
                              theme.colorScheme.primary.green,
                              theme.colorScheme.primary.blue,
                              0.3,
                            ),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.train, color: Colors.white, size: 28),
                    ),

                    const SizedBox(width: 16),

                    // Destination
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            theme.colorScheme.primary.red,
                            theme.colorScheme.primary.green,
                            theme.colorScheme.primary.blue,
                            0.05,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color.fromRGBO(
                              theme.colorScheme.primary.red,
                              theme.colorScheme.primary.green,
                              theme.colorScheme.primary.blue,
                              0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'To',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              route.destination ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Color.fromRGBO(
                    theme.colorScheme.primary.red,
                    theme.colorScheme.primary.green,
                    theme.colorScheme.primary.blue,
                    0.2,
                  ),
                  thickness: 1,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date & Time
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                              theme.colorScheme.primary.red,
                              theme.colorScheme.primary.green,
                              theme.colorScheme.primary.blue,
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color.fromRGBO(
                                theme.colorScheme.primary.red,
                                theme.colorScheme.primary.green,
                                theme.colorScheme.primary.blue,
                                0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                route.date != null
                                    ? '${route.date!.day}/${route.date!.month}/${route.date!.year}'
                                    : 'No date',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                              theme.colorScheme.primary.red,
                              theme.colorScheme.primary.green,
                              theme.colorScheme.primary.blue,
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color.fromRGBO(
                                theme.colorScheme.primary.red,
                                theme.colorScheme.primary.green,
                                theme.colorScheme.primary.blue,
                                0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.departure_board,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                route.time != null
                                    ? _formatTime(route.time ?? "")
                                    : 'No Time',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Book Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(
                              theme.colorScheme.primary.red,
                              theme.colorScheme.primary.green,
                              theme.colorScheme.primary.blue,
                              0.3,
                            ),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RouteDetailPage(route: route),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bookmark, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
