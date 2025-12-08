import 'package:flutter/material.dart';
import 'package:flutter_template/models/user_model.dart';
import 'package:flutter_template/utils/password_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _answerFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  int _currentStep = 1; // 1: Email, 2: Security Question, 3: Reset Password
  String? _securityQuestion;
  String? _userEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSubmit() async {
    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      // Check if user exists
      final userExists = await Users.checkUserExists(email);

      if (!userExists) {
        if (mounted) {
          _showErrorDialog(
            'Email Not Registered',
            'This email is not registered in our system. Please check your email or sign up.',
          );
        }
        return;
      }

      // Get security question
      final question = await Users.getSecurityQuestion(email);

      if (question == null) {
        if (mounted) {
          _showErrorDialog(
            'Account Recovery Not Set Up',
            'Account recovery is not set up for your account. Please contact the admin for assistance.',
          );
        }
        return;
      }

      // Move to next step
      if (mounted) {
        setState(() {
          _userEmail = email;
          _securityQuestion = question;
          _currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Error',
          'An unexpected error occurred: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAnswerSubmit() async {
    if (!_answerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final answer = _answerController.text.trim();

      // Verify answer using the database function
      final result = await Users.verifySecurityAnswer(_userEmail!, answer);

      if (result.startsWith('Success')) {
        // Move to password reset step
        if (mounted) {
          setState(() {
            _currentStep = 3;
          });
        }
      } else if (result.contains('Incorrect answer')) {
        if (mounted) {
          _showErrorDialog(
            'Incorrect Answer',
            'The answer you provided is incorrect. Please try again.',
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog('Error', result);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Error',
          'An unexpected error occurred: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    // Check if passwords match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog(
        'Passwords Do Not Match',
        'The new password and confirmation password do not match. Please try again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Encrypt the new password
      final encryptedPassword = PasswordHelper.encryptPassword(
        _newPasswordController.text,
      );

      // Reset password
      await Users.resetPassword(_userEmail!, encryptedPassword);

      if (mounted) {
        _showSuccessDialog(
          'Password Reset Successful',
          'Your password has been reset successfully. You can now sign in with your new password.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Failed to reset password: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Flexible(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Flexible(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to signin page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a0033),
                    const Color(0xFF2d1b4e),
                    const Color(0xFF3d2667),
                  ]
                : [
                    const Color(0xFF4a148c),
                    const Color(0xFF38006b),
                    const Color(0xFF2d004e),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),

                // Header
                Text(
                  _currentStep == 1
                      ? 'Forgot Password'
                      : _currentStep == 2
                      ? 'Security Question'
                      : 'Reset Password',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 28 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentStep == 1
                      ? 'Enter your email to begin account recovery'
                      : _currentStep == 2
                      ? 'Answer your security question'
                      : 'Enter your new password',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator(1, _currentStep >= 1),
                    _buildStepLine(_currentStep >= 2),
                    _buildStepIndicator(2, _currentStep >= 2),
                    _buildStepLine(_currentStep >= 3),
                    _buildStepIndicator(3, _currentStep >= 3),
                  ],
                ),
                const SizedBox(height: 40),

                // Content based on current step
                if (_currentStep == 1) _buildEmailStep(isSmallScreen),
                if (_currentStep == 2)
                  _buildSecurityQuestionStep(isSmallScreen),
                if (_currentStep == 3) _buildPasswordResetStep(isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Color(0xFF4a148c) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildEmailStep(bool isSmallScreen) {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: Colors.white30),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF4a148c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4a148c)),
                      ),
                    )
                  : Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityQuestionStep(bool isSmallScreen) {
    return Form(
      key: _answerFormKey,
      child: Column(
        children: [
          // Security question display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Security Question:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _securityQuestion ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Answer field
          TextFormField(
            controller: _answerController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Your Answer',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Enter your answer',
              hintStyle: TextStyle(color: Colors.white30),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Answer is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAnswerSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF4a148c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4a148c)),
                      ),
                    )
                  : Text(
                      'Verify Answer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetStep(bool isSmallScreen) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          // New password field
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Enter new password',
              hintStyle: TextStyle(color: Colors.white30),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase and number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Confirm new password',
              hintStyle: TextStyle(color: Colors.white30),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Reset password button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePasswordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF4a148c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4a148c)),
                      ),
                    )
                  : Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
