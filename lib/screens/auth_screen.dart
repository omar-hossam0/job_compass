import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedBackground(),
          IgnorePointer(
            ignoring: true,
            child: Stack(children: _buildFloatingIcons()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final verticalPadding = constraints.maxWidth >= 900 ? 48.0 : 32.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth >= 1200 ? 80 : 28,
                    vertical: verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (verticalPadding * 2),
                    ),
                    child: Center(
                      child: _buildContent(constraints),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    final isWide = constraints.maxWidth >= 900;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isWide ? 1100 : 600,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isWide ? 0.12 : 0.16),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.25),
              blurRadius: 40,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 28,
            vertical: isWide ? 48 : 36,
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildHeroSection(isWide)),
                    const SizedBox(width: 48),
                    SizedBox(
                      width: 340,
                      child: _buildActionCard(isWide),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeroSection(isWide),
                    const SizedBox(height: 32),
                    _buildActionCard(isWide),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isWide) {
    final align = isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
              isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/logo.png',
                height: 72,
                width: 72,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment:
                    isWide ? Alignment.centerLeft : Alignment.center,
                child: const _HeroTitle(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ResponsiveText(
          'Navigate your career with intelligent guidance',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          baseSize: isWide ? 34 : 28,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Text(
          'AI-powered job matching, personalised growth insights, and a\nseamless path from CV to your dream role - all in one place.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.82),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildActionCard(bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1E293B),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 28 : 24,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ready to explore?',
            style: TextStyle(
              fontSize: isWide ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue your journey or create a new account in seconds.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue with email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Create new account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                height: 1.5,
              ),
              children: const [
                TextSpan(
                  text: 'By continuing you agree to our ',
                ),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1B33), Color(0xFF123265), Color(0xFF1D4ED8)],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-1.1, -0.9),
            child: _blurCircle(const Color(0xFF38BDF8).withOpacity(0.35), 260),
          ),
          Align(
            alignment: const Alignment(1.2, -0.5),
            child: _blurCircle(const Color(0xFF2563EB).withOpacity(0.4), 320),
          ),
          Align(
            alignment: const Alignment(-0.8, 0.8),
            child: _blurCircle(const Color(0xFF60A5FA).withOpacity(0.28), 280),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.7,
            spreadRadius: size * 0.15,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingIcons() {
    final configs = [
      _FloatingLogoConfig(
        alignment: const Alignment(-0.9, -0.6),
        amplitude: 0.035,
        speed: 1.05,
        child: _linkedinLogo(),
      ),
      _FloatingLogoConfig(
        alignment: const Alignment(0.85, -0.35),
        amplitude: 0.04,
        speed: 0.9,
        child: _googleLogo(),
      ),
      _FloatingLogoConfig(
        alignment: const Alignment(-0.65, 0.4),
        amplitude: 0.045,
        speed: 1.25,
        child: _ibmLogo(),
      ),
      _FloatingLogoConfig(
        alignment: const Alignment(0.75, 0.55),
        amplitude: 0.05,
        speed: 1.1,
        child: _microsoftLogo(),
      ),
      _FloatingLogoConfig(
        alignment: const Alignment(-0.2, -0.85),
        amplitude: 0.032,
        speed: 1.35,
        child: _amazonLogo(),
      ),
    ];

    return configs
        .map(
          (config) => _FloatingLogo(
            animation: _floatController,
            config: config,
          ),
        )
        .toList();
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isCompact = width < 360;
    final textAlign = isWide ? TextAlign.left : TextAlign.center;
    final crossAlign =
        textAlign == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: crossAlign,
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveText(
          'JobCompass',
          textAlign: textAlign,
          baseSize: isWide ? 40 : 34,
          minSize: 26,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
          softWrap: false,
          maxLines: 1,
        ),
        const SizedBox(height: 6),
        Text(
          'Navigate Your Career',
          textAlign: textAlign,
          style: TextStyle(
            fontSize: isWide
                ? 18
                : (isCompact ? 14 : 16),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: const Color(0xFF93C5FD),
          ),
        ),
      ],
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final double baseSize;
  final double? minSize;
  final bool softWrap;
  final int? maxLines;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.textAlign,
    required this.baseSize,
    required this.style,
    this.minSize,
    this.softWrap = true,
    this.maxLines,
  });

  double _resolveFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double computed = baseSize;

    if (width < 360) {
      computed = baseSize * 0.82;
    }
    if (width < 320) {
      computed = baseSize * 0.72;
    }

    if (minSize != null && computed < minSize!) {
      computed = minSize!;
    }

    return computed;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSize = _resolveFontSize(context);
    return Text(
      text,
      textAlign: textAlign,
      style: style.copyWith(fontSize: resolvedSize),
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _FloatingLogo extends StatelessWidget {
  final Animation<double> animation;
  final _FloatingLogoConfig config;

  const _FloatingLogo({required this.animation, required this.config});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * 2 * math.pi * config.speed;
        final dx = math.sin(t) * config.amplitude;
        final dy = math.cos(t) * config.amplitude;
        return Align(
          alignment: Alignment(
            config.alignment.x + dx,
            config.alignment.y + dy,
          ),
          child: child,
        );
      },
      child: config.child,
    );
  }
}

class _FloatingLogoConfig {
  final Alignment alignment;
  final double amplitude;
  final double speed;
  final Widget child;

  const _FloatingLogoConfig({
    required this.alignment,
    required this.amplitude,
    required this.speed,
    required this.child,
  });
}

Widget _linkedinLogo() {
  return const _LogoBadge(
    background: Color(0xFF0A66C2),
    child: Text(
      'in',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1,
      ),
    ),
  );
}

Widget _googleLogo() {
  return const _LogoBadge(
    background: Colors.white,
    borderColor: Color(0xFFE2E8F0),
    child: Text(
      'G',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    ),
  );
}

Widget _ibmLogo() {
  return const _LogoBadge(
    background: Color(0xFF0F62FE),
    child: Text(
      'IBM',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: Colors.white,
      ),
    ),
  );
}

Widget _microsoftLogo() {
  return _LogoBadge(
    background: Colors.white,
    borderColor: const Color(0xFFE2E8F0),
    child: SizedBox(
      width: 30,
      height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LogoSquare(color: Color(0xFFF35325)),
              SizedBox(width: 4),
              _LogoSquare(color: Color(0xFF81BC06)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LogoSquare(color: Color(0xFF05A6F0)),
              SizedBox(width: 4),
              _LogoSquare(color: Color(0xFFFECB00)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _amazonLogo() {
  return _LogoBadge(
    background: const Color(0xFF232F3E),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'amazon',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 2),
        Icon(
          Icons.check,
          size: 12,
          color: Color(0xFFFBBF24),
        ),
      ],
    ),
  );
}

class _LogoBadge extends StatelessWidget {
  final double size;
  final double borderRadius;
  final Color background;
  final Color? borderColor;
  final Widget child;

  const _LogoBadge({
    required this.child,
    required this.background,
    this.size = 60,
    this.borderRadius = 20,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = child is SizedBox ? child : Center(child: child);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.2)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _LogoSquare extends StatelessWidget {
  final Color color;

  const _LogoSquare({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
