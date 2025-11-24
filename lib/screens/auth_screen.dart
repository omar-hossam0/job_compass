import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_dashboard_screen.dart';
import 'sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Profile images
                _buildProfileImages(),

                const SizedBox(height: 28),

                // Title and subtitle
                const Text(
                  'Discover the perfect',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff070C19),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'job tailored just for you',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff070C19),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tailored job search: find your perfect fit',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'effortlessly.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Facebook button
                _buildSocialButton(
                  onTap: () {
                    // Handle Facebook login
                    _navigateToHome();
                  },
                  icon: FontAwesomeIcons.facebook,
                  iconColor: const Color(0xff1877F2),
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey[300]!,
                  text: 'Continue with Facebook',
                  textColor: const Color(0xff070C19),
                ),

                const SizedBox(height: 12),

                // Google button
                _buildSocialButton(
                  onTap: () {
                    // Handle Google login
                    _navigateToHome();
                  },
                  icon: FontAwesomeIcons.google,
                  iconColor: null, // Will use multicolor gradient
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey[300]!,
                  text: 'Continue with Google',
                  textColor: const Color(0xff070C19),
                ),

                const SizedBox(height: 14),

                // Email button
                _buildEmailButton(),

                const SizedBox(height: 20),

                // Create account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff3F6CDF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Terms and Privacy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'By proceeding, you hereby agree to abide by our ',
                        ),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: Color(0xff3F6CDF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Color(0xff3F6CDF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImages() {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left small circle
          Positioned(
            left: 20,
            top: 10,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xffC8F5E8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/profile1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xffC8F5E8),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xff070C19),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Center large circle
          Positioned(
            bottom: 0,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                color: const Color(0xffC8F5E8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/profile2.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xffC8F5E8),
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Color(0xff070C19),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Right small circle
          Positioned(
            right: 20,
            top: 8,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xffFFE5D9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/profile3.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xffFFE5D9),
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: Color(0xff070C19),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    Color? iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String text,
    required Color textColor,
  }) {
    // Build icon inside a white circular badge
    Widget iconBadge;
    if (icon == FontAwesomeIcons.google && iconColor == null) {
      iconBadge = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xff4285F4),
                Color(0xffDB4437),
                Color(0xffF4B400),
                Color(0xff0F9D58),
              ],
            ).createShader(bounds),
            child: const FaIcon(
              FontAwesomeIcons.google,
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      iconBadge = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(child: FaIcon(icon, size: 22, color: iconColor)),
      );
    }

    // Use a Stack so the icon appears on the left while text remains centered
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered text
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            // Left icon
            Positioned(left: 14, child: iconBadge),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailButton() {
    return GestureDetector(
      onTap: () {
        // Handle email login
        _navigateToHome();
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xff2C7A77),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
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
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
    );
  }
}
