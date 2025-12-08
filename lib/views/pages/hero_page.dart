import 'package:flutter/material.dart';
import 'package:flutter_template/views/pages/signin_page.dart';
import 'package:flutter_template/views/pages/signup_page.dart';

class HeroPage extends StatelessWidget {
  const HeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Gradient Background
            Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Stack(
                children: [
                  // Background Image with rounded corners for large screens
                  Positioned.fill(
                    child: isLargeScreen
                        ? Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    'https://images.unsplash.com/photo-1474487548417-781cb71495f3?q=80&w=2000',
                                    fit: BoxFit.cover,
                                  ),
                                  // Gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                const Color(
                                                  0xFF1a0033,
                                                ).withValues(alpha: 0.85),
                                                const Color(
                                                  0xFF2d1b4e,
                                                ).withValues(alpha: 0.85),
                                                const Color(
                                                  0xFF3d2667,
                                                ).withValues(alpha: 0.85),
                                              ]
                                            : [
                                                const Color(
                                                  0xFF4a148c,
                                                ).withValues(alpha: 0.85),
                                                const Color(
                                                  0xFF38006b,
                                                ).withValues(alpha: 0.85),
                                                const Color(
                                                  0xFF2d004e,
                                                ).withValues(alpha: 0.85),
                                              ],
                                      ),
                                    ),
                                  ),
                                  // Decorative circles
                                  Positioned(
                                    top: -50,
                                    right: -50,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -100,
                                    left: -100,
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(
                                              alpha: 0.08,
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1474487548417-781cb71495f3?q=80&w=2000',
                                ),
                                fit: BoxFit.cover,
                                opacity: 0.3,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        const Color(
                                          0xFF1a0033,
                                        ).withValues(alpha: 0.9),
                                        const Color(
                                          0xFF2d1b4e,
                                        ).withValues(alpha: 0.9),
                                        const Color(
                                          0xFF3d2667,
                                        ).withValues(alpha: 0.9),
                                      ]
                                    : [
                                        const Color(
                                          0xFF4a148c,
                                        ).withValues(alpha: 0.9),
                                        const Color(
                                          0xFF38006b,
                                        ).withValues(alpha: 0.9),
                                        const Color(
                                          0xFF2d004e,
                                        ).withValues(alpha: 0.9),
                                      ],
                              ),
                            ),
                          ),
                  ),
                  // Content
                  Positioned.fill(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo and Title
                            // add logo here
                            // const Icon(
                            //   Icons.train_rounded,
                            //   size: 100,
                            //   color: Colors.white,
                            // ),
                            const SizedBox(height: 24),
                            const Text(
                              'BookFlee',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 10,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Journey, Our Priority',
                              style: TextStyle(
                                fontSize: 22,
                                color: const Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.95,
                                ),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 50),
                            // Description
                            Container(
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width < 600
                                    ? 16
                                    : 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Book Your Train Tickets Online',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 18
                                          : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width < 600
                                        ? 8
                                        : 16,
                                  ),
                                  Text(
                                    'Experience seamless train ticket booking with Bookflee. '
                                    'Choose from hundreds of routes, secure your seats instantly, '
                                    'and travel with confidence across the country.',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 14
                                          : 16,
                                      color: Colors.white,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width < 600
                                  ? 24
                                  : 40,
                            ),
                            // CTA Buttons
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Navigate to sign up
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SignUpPage();
                                        },
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 24
                                          : 32,
                                      vertical:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 12
                                          : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_add,
                                        size:
                                            MediaQuery.of(context).size.width <
                                                600
                                            ? 18
                                            : 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width <
                                                  600
                                              ? 16
                                              : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    // TODO: Navigate to login
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text('Login coming soon...'),
                                    //     duration: Duration(seconds: 2),
                                    //   ),

                                    // );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SignInPage();
                                        },
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 24
                                          : 32,
                                      vertical:
                                          MediaQuery.of(context).size.width <
                                              600
                                          ? 12
                                          : 16,
                                    ),
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.login,
                                        size:
                                            MediaQuery.of(context).size.width <
                                                600
                                            ? 18
                                            : 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width <
                                                  600
                                              ? 16
                                              : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // What We Offer Section
            Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 600 ? 20.0 : 40.0,
              ),
              child: Column(
                children: [
                  Text(
                    'What We Offer',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600
                          ? 24
                          : 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 600 ? 8 : 16,
                  ),
                  Text(
                    'Everything you need for a perfect train journey',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600
                          ? 14
                          : 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 600 ? 24 : 40,
                  ),
                  _buildServiceCard(
                    context,
                    Icons.search,
                    'Easy Search',
                    'Find the perfect train route with our intuitive search system. '
                        'Browse through multiple options and choose what suits you best.',
                  ),
                  const SizedBox(height: 20),
                  _buildServiceCard(
                    context,
                    Icons.payment,
                    'Secure Payments',
                    'Book with confidence using our encrypted payment gateway. '
                        'Multiple payment options available for your convenience.',
                  ),
                  const SizedBox(height: 20),
                  _buildServiceCard(
                    context,
                    Icons.confirmation_number,
                    'Instant Booking',
                    'Get your tickets instantly after booking. No waiting, no hassle. '
                        'Digital tickets sent directly to your email and app.',
                  ),
                  const SizedBox(height: 20),
                  _buildServiceCard(
                    context,
                    Icons.notifications_active,
                    'Real-time Updates',
                    'Stay informed with live train status, platform changes, and delays. '
                        'Never miss important updates about your journey.',
                  ),
                  const SizedBox(height: 20),
                  _buildServiceCard(
                    context,
                    Icons.support_agent,
                    '24/7 Customer Support',
                    'Our dedicated support team is always ready to help you. '
                        'Reach us anytime via chat, email, or phone.',
                  ),
                  const SizedBox(height: 20),
                  _buildServiceCard(
                    context,
                    Icons.discount,
                    'Best Prices',
                    'Compare prices and get the best deals on train tickets. '
                        'Special discounts and offers available regularly.',
                  ),
                ],
              ),
            ),

            // Statistics Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width < 600 ? 30 : 50,
                horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
              ),
              child: Column(
                children: [
                  Text(
                    'Trusted by Thousands',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600
                          ? 24
                          : 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 600 ? 24 : 40,
                  ),
                  MediaQuery.of(context).size.width < 600
                      ? Wrap(
                          alignment: WrapAlignment.spaceAround,
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildStatCard(context, '50K+', 'Happy Travelers'),
                            _buildStatCard(context, '500+', 'Train Routes'),
                            _buildStatCard(context, '24/7', 'Support'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(context, '50K+', 'Happy Travelers'),
                            _buildStatCard(context, '500+', 'Train Routes'),
                            _buildStatCard(context, '24/7', 'Support'),
                          ],
                        ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width < 600 ? 20 : 30,
                horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 40,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1a0033), const Color(0xFF2d1b4e)]
                      : [const Color(0xFF38006b), const Color(0xFF2d004e)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //add logo here
                      // Icon(Icons.train_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'BookFlee',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 600
                              ? 18
                              : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: MediaQuery.of(context).size.width < 600
                              ? 5
                              : 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 600 ? 8 : 16,
                  ),
                  Text(
                    '© 2025 BookFlee. All rights reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromRGBO(255, 255, 255, 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  theme.colorScheme.primary.red,
                  theme.colorScheme.primary.green,
                  theme.colorScheme.primary.blue,
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: isSmallScreen ? 24 : 32,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String number, String label) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
