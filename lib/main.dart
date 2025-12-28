import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/profile_cv_screen.dart';
import 'screens/skill_analysis_screen.dart';
import 'screens/job_matches_screen.dart';
import 'screens/job_details_screen.dart';
import 'screens/skill_gap_screen.dart';
import 'screens/learning_path_screen.dart';
import 'screens/interview_prep_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/hr_dashboard_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/post_job_screen.dart';
import 'screens/hr_job_details_screen.dart';
import 'screens/candidate_list_screen.dart';
import 'screens/candidate_details_screen.dart';
import 'screens/hr_notifications_screen.dart';
import 'screens/hr_settings_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/job_analysis_result_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize API service token
  await ApiService().initToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Compass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/dashboard': (_) => const StudentDashboardScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/profile-cv': (_) => const ProfileCVScreen(),
        '/skills-analysis': (_) => const SkillAnalysisScreen(),
        '/job-matches': (_) => const JobMatchesScreen(),
        '/learning-path': (_) => const LearningPathScreen(),
        '/interview-prep': (_) => const InterviewPrepScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/chatbot': (_) => const ChatbotScreen(),
        '/hr/dashboard': (_) => const HRDashboardScreen(),
        '/hr/jobs': (_) => const JobListScreen(),
        '/hr/post-job': (_) => const PostJobScreen(),
        '/hr/notifications': (_) => const HRNotificationsScreen(),
        '/hr/settings': (_) => const HRSettingsScreen(),
      },
      onGenerateRoute: (settings) {
        // For routes with parameters
        if (settings.name == '/job-details') {
          final jobId = settings.arguments as String?;
          if (jobId != null) {
            return MaterialPageRoute(
              builder: (_) => JobDetailsScreen(jobId: jobId),
            );
          }
        }
        if (settings.name == '/skill-gap') {
          final jobId = settings.arguments as String?;
          if (jobId != null) {
            return MaterialPageRoute(
              builder: (_) => SkillGapScreen(jobId: jobId),
            );
          }
        }
        if (settings.name == '/hr/job-details') {
          final jobId = settings.arguments as String?;
          if (jobId != null) {
            return MaterialPageRoute(
              builder: (_) => HRJobDetailsScreen(jobId: jobId),
            );
          }
        }
        if (settings.name == '/hr/candidates') {
          final jobId = settings.arguments as String?;
          if (jobId != null) {
            return MaterialPageRoute(
              builder: (_) => CandidateListScreen(jobId: jobId),
            );
          }
        }
        if (settings.name == '/hr/candidate-details') {
          final candidateId = settings.arguments as String?;
          if (candidateId != null) {
            return MaterialPageRoute(
              builder: (_) => CandidateDetailsScreen(candidateId: candidateId),
            );
          }
        }
        if (settings.name == '/job-analysis') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final jobId = args['jobId'] as String?;
            final jobTitle = args['jobTitle'] as String?;
            if (jobId != null) {
              return MaterialPageRoute(
                builder: (_) =>
                    JobAnalysisResultScreen(jobId: jobId, jobTitle: jobTitle),
              );
            }
          } else if (args is String) {
            return MaterialPageRoute(
              builder: (_) => JobAnalysisResultScreen(jobId: args),
            );
          }
        }
        return null;
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive splash: use MediaQuery to scale logo and fonts and allow scrolling on very small screens
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final horizontalPadding = (w * 0.06).clamp(16.0, 40.0);
    final logoSize = (w * 0.45).clamp(100.0, 220.0);
    final titleFont = (w * 0.12).clamp(22.0, 42.0); // scaled title
    final subtitleFont = (w * 0.06).clamp(14.0, 24.0);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Allow vertical scrolling if the available height is constrained
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Responsive logo (keeps aspect and scales down on small screens)
                        SizedBox(
                          width: logoSize,
                          height: logoSize,
                          child: TransparentLogo(
                            assetPath: 'assets/images/logo.png',
                            tolerance: 40,
                          ),
                        ),

                        SizedBox(height: h * 0.03),

                        // App Name scaled and wrapped in FittedBox to prevent forced wrapping
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'JobCompass',
                            style: TextStyle(
                              fontSize: titleFont,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: h * 0.02),

                        Text(
                          'Navigate Your Career',
                          style: TextStyle(
                            fontSize: subtitleFont.clamp(14.0, 24.0),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff60a5fa),
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtitle (allow wrapping and smaller fonts on small screens)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'AI-powered CV matching that finds your perfect career path with intelligent job recommendations',
                            style: TextStyle(
                              fontSize: (w * 0.04).clamp(12.0, 16.0),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xffbfdbfe),
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: h * 0.03),

                        // Feature indicators with icons (wrap on small widths)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildFeatureIcon(
                              Icons.psychology_outlined,
                              'AI Powered',
                            ),
                            _buildFeatureIcon(
                              Icons.trending_up,
                              'Career Growth',
                            ),
                            _buildFeatureIcon(Icons.work_outline, 'Job Match'),
                          ],
                        ),
                        SizedBox(height: h * 0.03),

                        // Start Now Button (single, compact and responsive)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xff3b82f6,
                                ).withOpacity(0.28),
                                blurRadius: 18,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const OnboardingScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                          begin: begin,
                                          end: end,
                                        ).chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(
                                          tween,
                                        );
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff3b82f6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: (w * 0.08).clamp(20.0, 40.0),
                                vertical: (h * 0.018).clamp(12.0, 20.0),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start Now',
                                  style: TextStyle(
                                    fontSize: (w * 0.045).clamp(14.0, 18.0),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ), // Column
                  ), // Padding
                ), // ConstrainedBox
              ); // SingleChildScrollView
            },
          ), // LayoutBuilder
        ), // SafeArea
      ), // Container
    ); // Scaffold
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff3b82f6).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 28, color: const Color(0xff60a5fa)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xffbfdbfe),
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
