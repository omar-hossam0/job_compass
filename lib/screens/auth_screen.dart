import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Profile Images (3 circles)
                      _buildProfileImages(),

                      const SizedBox(height: 40),

                      // Title and subtitle
                      const Text(
                        'Discover the perfect',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'job tailored just for you',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Tailored job search: find your perfect fit effortlessly.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Buttons Container
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Email button only
                            _buildEmailButton(),

                            const SizedBox(height: 20),

                            // Create account link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Terms and Privacy
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9E9E),
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'By proceeding, you hereby agree to abide by our\n',
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImages() {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left circle
          Positioned(
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFB8E6D5).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Center circle (larger)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFB8E6D5).withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 60, color: Color(0xFF1A1A1A)),
          ),
          // Right circle
          Positioned(
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF2C7A77),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C7A77).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Continue with email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
