import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'onboarding_career_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff1a2332), Color(0xff1e3a5f), Color(0xff2563eb)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  _buildLogo(),

                  const SizedBox(height: 50),

                  // App Name
                  const Text(
                    'JobCompass',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  const Text(
                    'Navigate Your Career',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff60a5fa),
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'AI-powered CV matching that finds your perfect career path with intelligent job recommendations',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffcbd5e1),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Features
                  _buildFeatures(),

                  const SizedBox(height: 60),

                  // Start Now Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const OnboardingCareerScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff3b82f6),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff3b82f6).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start Now',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 140,
      height: 140,
      child: TransparentLogo(
        assetPath: 'assets/images/logo.png',
        tolerance: 40,
      ),
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildFeatureItem(icon: Icons.psychology_outlined, label: 'AI Powered'),
        _buildFeatureItem(icon: Icons.trending_up, label: 'Career Growth'),
        _buildFeatureItem(icon: Icons.work_outline, label: 'Job Match'),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xff60a5fa).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 28, color: const Color(0xff60a5fa)),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xffcbd5e1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Widget that loads an image asset, detects the dominant corner background
/// color and makes pixels close to that color fully transparent.
class TransparentLogo extends StatefulWidget {
  final String assetPath;
  final int tolerance; // color tolerance (0-255)
  const TransparentLogo({
    super.key,
    required this.assetPath,
    this.tolerance = 30,
  });

  @override
  State<TransparentLogo> createState() => _TransparentLogoState();
}

class _TransparentLogoState extends State<TransparentLogo> {
  Uint8List? _pngBytes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    if (_busy) return;
    _busy = true;
    try {
      final data = await rootBundle.load(widget.assetPath);
      final bytes = data.buffer.asUint8List();

      // Decode into a ui.Image so we can access raw RGBA bytes reliably
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final srcImage = frame.image;
      final width = srcImage.width;
      final height = srcImage.height;

      final bd = await srcImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bd == null) return;
      final pixels = bd.buffer.asUint8List();

      int idxOf(int x, int y) => (y * width + x) * 4;

      // Sample the four corners
      final corners = [
        idxOf(0, 0),
        idxOf(width - 1, 0),
        idxOf(0, height - 1),
        idxOf(width - 1, height - 1),
      ];

      int rSum = 0, gSum = 0, bSum = 0;
      for (final c in corners) {
        rSum += pixels[c];
        gSum += pixels[c + 1];
        bSum += pixels[c + 2];
      }
      final rAvg = (rSum / corners.length).round();
      final gAvg = (gSum / corners.length).round();
      final bAvg = (bSum / corners.length).round();

      final tol = widget.tolerance;
      final tolSq = tol * tol;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final i = idxOf(x, y);
          final pr = pixels[i];
          final pg = pixels[i + 1];
          final pb = pixels[i + 2];
          final dr = pr - rAvg;
          final dg = pg - gAvg;
          final db = pb - bAvg;
          final distSq = dr * dr + dg * dg + db * db;
          if (distSq <= tolSq) {
            // make pixel transparent
            pixels[i + 3] = 0;
          }
        }
      }

      // Re-create a ui.Image from modified RGBA bytes
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(pixels, width, height, ui.PixelFormat.rgba8888, (
        ui.Image img,
      ) {
        completer.complete(img);
      });
      final newImg = await completer.future;
      final pngBd = await newImg.toByteData(format: ui.ImageByteFormat.png);
      if (pngBd != null) {
        setState(() {
          _pngBytes = pngBd.buffer.asUint8List();
        });
      }
    } catch (e) {
      debugPrint('TransparentLogo processing failed: $e');
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pngBytes != null) {
      return Image.memory(_pngBytes!, fit: BoxFit.contain);
    }

    // while processing, show the original asset (so user doesn't see empty)
    return Image.asset(widget.assetPath, fit: BoxFit.contain);
  }
}
