import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'profile_screen.dart';
import 'job_detail_screen.dart';
import 'jobs_screen.dart';
import 'saved_screen.dart';
import 'chat_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Animated counters
  int _remoteJobsCount = 0;
  int _fullTimeJobsCount = 0;
  int _partTimeJobsCount = 0;
  
  final int _targetRemoteJobs = 48300;
  final int _targetFullTimeJobs = 78300;
  final int _targetPartTimeJobs = 29500;
  
  // Saved jobs state
  final Set<String> _savedJobIds = {};
  late List<Map<String, dynamic>> _allJobs;

  @override
  void initState() {
    super.initState();
    _allJobs = _getAllJobs();
    _startCounterAnimations();
  }

  List<Map<String, dynamic>> _getAllJobs() {
    return [
      {
        'id': 'youtube_1',
        'company': 'Youtube',
        'location': 'San Bruno, California, USA',
        'title': 'Senior UX Researcher',
        'type': 'Full Time',
        'salary': '\$8K - \$10K',
        'logo': Icons.play_circle_filled,
        'logoColor': const Color(0xffFF0000),
      },
      {
        'id': 'apple_1',
        'company': 'Apple',
        'location': 'Cupertino, California',
        'title': 'Junior Product Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$15K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'facebook_1',
        'company': 'Facebook',
        'location': 'Menlo Park, California',
        'title': 'UI/UX Designer',
        'type': 'Full Time',
        'salary': '\$8K - \$12K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      {
        'id': 'google_1',
        'company': 'Google',
        'location': 'Mountain View, California',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$7K - \$11K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'microsoft_1',
        'company': 'Microsoft',
        'location': 'Redmond, Washington',
        'title': 'Senior Designer',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
    ];
  }

  void _toggleSaveJob(String jobId) {
    setState(() {
      if (_savedJobIds.contains(jobId)) {
        _savedJobIds.remove(jobId);
      } else {
        _savedJobIds.add(jobId);
      }
    });
  }

  void _startCounterAnimations() {
    // Animate remote jobs counter
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_remoteJobsCount < _targetRemoteJobs) {
        setState(() {
          _remoteJobsCount += 500;
          if (_remoteJobsCount > _targetRemoteJobs) {
            _remoteJobsCount = _targetRemoteJobs;
          }
        });
      } else {
        timer.cancel();
      }
    });
    
    // Animate full time jobs counter
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_fullTimeJobsCount < _targetFullTimeJobs) {
        setState(() {
          _fullTimeJobsCount += 600;
          if (_fullTimeJobsCount > _targetFullTimeJobs) {
            _fullTimeJobsCount = _targetFullTimeJobs;
          }
        });
      } else {
        timer.cancel();
      }
    });
    
    // Animate part time jobs counter
    Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (_partTimeJobsCount < _targetPartTimeJobs) {
        setState(() {
          _partTimeJobsCount += 300;
          if (_partTimeJobsCount > _targetPartTimeJobs) {
            _partTimeJobsCount = _targetPartTimeJobs;
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).size.height * 0.12;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildReminder(),
                    const SizedBox(height: 24),
                    _buildDiscoverSection(),
                    const SizedBox(height: 24),
                    _buildPopularJobsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildFloatingBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Omar Hossam',
                style: TextStyle(
                  color: Color(0xff070C19),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.search, color: Color(0xff070C19), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildReminder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Reminder ',
                      style: TextStyle(
                        color: Color(0xff070C19),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '👋',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Today at 2:00 PM, You have an interview at Creole Studios.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xff070C19),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Discover Your Dream Job',
            style: TextStyle(
              color: Color(0xff070C19),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildJobTypeCard(
                  icon: Icons.home_work_outlined,
                  count: _remoteJobsCount,
                  label: 'Remote Jobs',
                  color: const Color(0xffC3D1F5),
                  iconColor: const Color(0xff3F6CDF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildJobTypeCard(
                      icon: Icons.business_center_outlined,
                      count: _fullTimeJobsCount,
                      label: 'Full Time',
                      color: const Color(0xffFFF4CC),
                      iconColor: const Color(0xffFFA500),
                      isSmall: true,
                    ),
                    const SizedBox(height: 12),
                    _buildJobTypeCard(
                      icon: Icons.access_time,
                      count: _partTimeJobsCount,
                      label: 'Part Time',
                      color: const Color(0xffFFCDD2),
                      iconColor: const Color(0xffF44336),
                      isSmall: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobTypeCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required Color iconColor,
    bool isSmall = false,
  }) {
    final displayCount = count >= 1000 
        ? '${(count / 1000).toStringAsFixed(1)}K'
        : count.toString();

    return Container(
      height: isSmall ? 100 : 212,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: isSmall ? 24 : 32),
          ),
          const SizedBox(height: 12),
          Text(
            displayCount,
            style: TextStyle(
              color: const Color(0xff070C19),
              fontSize: isSmall ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Most Popular Jobs',
                style: TextStyle(
                  color: Color(0xff070C19),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          JobsScreen(
                        savedJobIds: _savedJobIds.toList(),
                        onToggleSave: _toggleSaveJob,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 0.1);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: const Text(
                  'Show All',
                  style: TextStyle(
                    color: Color(0xff3F6CDF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _allJobs.length,
            itemBuilder: (context, index) {
              final job = _allJobs[index];
              final isSaved = _savedJobIds.contains(job['id']);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(job: job),
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    right: index == _allJobs.length - 1 ? 0 : 12,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  job['logo'] as IconData,
                                  color: job['logoColor'] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job['company'] as String,
                                    style: const TextStyle(
                                      color: Color(0xff070C19),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    job['location'] as String,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _toggleSaveJob(job['id'] as String),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? const Color(0xff3F6CDF) : Colors.grey[400],
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        job['title'] as String,
                        style: const TextStyle(
                          color: Color(0xff070C19),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['type'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            job['salary'] as String,
                            style: const TextStyle(
                              color: Color(0xff070C19),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff070C19),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Apply Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xff070C19).withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff070C19).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.work_outline_rounded, 'Jobs', 1),
              _navItem(Icons.bookmark_outline, 'Saved', 2),
              _navItem(Icons.chat_bubble_outline, 'Chat', 3),
              _navItem(Icons.person_outline_rounded, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onNavTap(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xff3F6CDF) : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xff3F6CDF) : Colors.white60,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    Widget destination;
    switch (index) {
      case 0:
        return; // Home - already here
      case 1:
        destination = JobsScreen(
          savedJobIds: _savedJobIds.toList(),
          onToggleSave: _toggleSaveJob,
        );
        break;
      case 2:
        destination = SavedScreen(
          savedJobIds: _savedJobIds.toList(),
          allSavedJobs: _allJobs,
          onToggleSave: _toggleSaveJob,
        );
        break;
      case 3:
        destination = const ChatScreen();
        break;
      case 4:
        destination = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}