import 'package:flutter/material.dart';
import 'package:flutter_template/models/customer_model.dart';
import 'package:flutter_template/views/pages/signin_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phonecontroller = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  DateTime? _selectedDate;
  String? _selectedGender;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phonecontroller.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _handleSignUp() async {
    // 1. Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the register function
      final List<Map<String, dynamic>> response = await Customer.Register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedDate as DateTime,
        _selectedGender == "Male" ? 1 : 0,
        _phonecontroller.text.trim(),
        "customer",
      );

      // Check if response is empty or contains an error
      if (response.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-up failed! No response from server.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // If we reach here, registration was successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to sign-in page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } on PostgrestException catch (e) {
      // Handle Supabase database errors
      String errorMessage = 'Database error occurred';

      if (e.code == '23505') {
        errorMessage =
            'This email is already registered. Please sign in or use a different email.';
      } else if (e.code == '23502') {
        errorMessage = 'Please fill in all required fields.';
      } else if (e.code == '23503') {
        errorMessage = 'Invalid reference data provided.';
      } else if (e.message.contains('duplicate key')) {
        errorMessage = 'This email is already registered.';
      } else {
        errorMessage = 'Database error: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Handle all other errors
      String errorMessage = e.toString();

      // Clean up the error message if it starts with "Exception: "
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always stop loading, whether it failed or succeeded
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1474487548417-781cb71495f3?q=80&w=2000',
            ),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a0033).withValues(alpha: 0.95),
                    const Color(0xFF2d1b4e).withValues(alpha: 0.95),
                    const Color(0xFF3d2667).withValues(alpha: 0.95),
                  ]
                : [
                    const Color(0xFF4a148c).withValues(alpha: 0.95),
                    const Color(0xFF38006b).withValues(alpha: 0.95),
                    const Color(0xFF2d004e).withValues(alpha: 0.95),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    //add logo later
                    const SizedBox(height: 12),
                    const Text(
                      'BookFlee',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromRGBO(255, 255, 255, 0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sign Up Title
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join us and start your journey',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),

                              // First Name & Last Name Row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      decoration: InputDecoration(
                                        labelText: 'First Name',
                                        hintText: 'Randy',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: theme.colorScheme.primary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.grey[850]
                                            : Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Last Name',
                                        hintText: 'Orton',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: theme.colorScheme.primary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.grey[850]
                                            : Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'your.email@example.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: theme.colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _phonecontroller,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  hintText: '',
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: theme.colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Date of Birth Field
                              TextFormField(
                                controller: _dateOfBirthController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  hintText: 'Select your date of birth',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    color: theme.colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your date of birth';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Gender Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: Icon(
                                    Icons.wc,
                                    color: theme.colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text('Female'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your gender';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: theme.colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: theme.colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Sign Up Button
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Sign In Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return SignInPage();
                                          },
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 24),

                    // Back to Home
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        'Back to Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
