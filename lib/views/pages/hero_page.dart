import 'package:flutter/material.dart';
import 'package:flutter_template/views/pages/signin_page.dart';
import 'package:flutter_template/views/pages/signup_page.dart';

class HeroPage extends StatelessWidget {
  const HeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Gradient Background
            Container(
              height: MediaQuery.of(context).size.height * 0.75,
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
                          const Color(0xFF1a0033).withValues(alpha: 0.9),
                          const Color(0xFF2d1b4e).withValues(alpha: 0.9),
                          const Color(0xFF3d2667).withValues(alpha: 0.9),
                        ]
                      : [
                          const Color(0xFF4a148c).withValues(alpha: 0.9),
                          const Color(0xFF38006b).withValues(alpha: 0.9),
                          const Color(0xFF2d004e).withValues(alpha: 0.9),
                        ],
                ),
              ),
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
                          color: const Color.fromRGBO(255, 255, 255, 0.95),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Description
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Book Your Train Tickets Online',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Experience seamless train ticket booking with Bookflee. '
                              'Choose from hundreds of routes, secure your seats instantly, '
                              'and travel with confidence across the country.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // CTA Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.person_add, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.login, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
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

            // What We Offer Section
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Text(
                    'What We Offer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Everything you need for a perfect train journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 40),
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
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
              ),
              child: Column(
                children: [
                  Text(
                    'Trusted by Thousands',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //add logo here
                      // Icon(Icons.train_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'BookFlee',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  theme.colorScheme.primary.red,
                  theme.colorScheme.primary.green,
                  theme.colorScheme.primary.blue,
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
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
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
