import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToSignIn() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final illustrationSize = math.min(w * 0.55, 220.0);
    final horizontalPadding = math.min(32.0, w * 0.08);
    final titleFontSize = w < 360 ? 20.0 : 28.0;
    final descFontSize = w < 360 ? 14.0 : 16.0;
    final verticalSpacing = w < 360 ? 36.0 : 60.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff0f172a), Color(0xff1e293b), Color(0xff1e40af)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with Skip button and indicators
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // small logo placeholder (keeps space for alignment)
                    SizedBox(width: math.min(56.0, w * 0.14)),

                    // Page indicators
                    Row(
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xff60a5fa)
                                : Colors.white.withOpacity(0.28),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Skip button
                    TextButton(
                      onPressed: _skipToSignIn,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    _onboardingPage(
                      illustrationSize: illustrationSize,
                      icon: Icons.explore_outlined,
                      title: 'Find the Right Job for Your Skills',
                      description:
                          'We analyze your skills and recommend the best job matches.',
                      titleFontSize: titleFontSize,
                      descFontSize: descFontSize,
                      verticalSpacing: verticalSpacing,
                      // no extra badge for page 1
                    ),
                    _onboardingPage(
                      illustrationSize: illustrationSize,
                      icon: Icons.analytics_outlined,
                      title: 'Understand the Gap to Your Target Job',
                      description:
                          'Discover missing skills and how to build them.',
                      titleFontSize: titleFontSize,
                      descFontSize: descFontSize,
                      verticalSpacing: verticalSpacing,
                      badge: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xff60a5fa),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_graph,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    _onboardingPage(
                      illustrationSize: illustrationSize,
                      icon: Icons.school_outlined,
                      title: 'Personalized Learning Plan',
                      description:
                          'Recommended courses and clear steps tailored to your needs.',
                      titleFontSize: titleFontSize,
                      descFontSize: descFontSize,
                      verticalSpacing: verticalSpacing,
                      badge: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xfff59e0b),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: _currentPage == 2
                    ? _buildStartButton()
                    : _buildNextButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onboardingPage({
    required double illustrationSize,
    required IconData icon,
    required String title,
    required String description,
    required double titleFontSize,
    required double descFontSize,
    required double verticalSpacing,
    Widget? badge,
  }) {
    // Make onboarding content adapt to available height. If space is constrained,
    // allow vertical scrolling to avoid overflow on small phones.
    return LayoutBuilder(
      builder: (context, constraints) {
        final availH = constraints.maxHeight;
        // Further clamp illustration size so it doesn't eat too much vertical space
        final maxIllustFromHeight = availH * 0.34;
        final adjustedIllustrationSize = math.min(
          illustrationSize,
          maxIllustFromHeight,
        );

        // Make title size responsive to both width and height; clamp to reasonable range
        double calcTitleSize() {
          final w = MediaQuery.of(context).size.width;
          final h = availH;
          // base from width
          final baseW = math.max(16.0, w * 0.08);
          // scale a bit with height
          final scaled = baseW * (h / 780).clamp(0.8, 1.15);
          return scaled.clamp(16.0, 30.0);
        }

        final effectiveTitleSize = calcTitleSize();
        final effectiveDescSize = descFontSize.clamp(12.0, 16.0);
        final effectiveVerticalSpacing = (verticalSpacing * (availH / 820))
            .clamp(18.0, 80.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availH),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: math.min(
                  32.0,
                  MediaQuery.of(context).size.width * 0.08,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Illustration container
                  Container(
                    width: adjustedIllustrationSize,
                    height: adjustedIllustrationSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          icon,
                          size: adjustedIllustrationSize * 0.55,
                          color: const Color(0xff60a5fa).withOpacity(0.9),
                        ),
                        if (badge != null)
                          Positioned(right: 20, top: 16, child: badge),
                      ],
                    ),
                  ),

                  SizedBox(height: effectiveVerticalSpacing),

                  // Title - limit to 2 lines to avoid wrapping weirdly on very small widths
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: effectiveTitleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // Description - allow wrapping but keep font within bounds
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: effectiveDescSize,
                      color: const Color(0xffbfdbfe),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff3b82f6),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Next',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _skipToSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff3b82f6),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
