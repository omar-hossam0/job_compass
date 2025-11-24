import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../constants/jobs_data.dart';
import 'profile_screen.dart';
import 'job_detail_screen.dart';
import 'jobs_screen.dart';
import 'saved_screen.dart';
// removed old chat_screen - using chat_bot_screen instead
import 'chat_bot_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with TickerProviderStateMixin {
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
    return JobsData.allJobs.map((job) {
      final jobCopy = Map<String, dynamic>.from(job);
      jobCopy['logo'] = JobsData.getCompanyLogo(job['company']);
      jobCopy['logoColor'] = JobsData.getCompanyColor(job['company']);
      return jobCopy;
    }).toList();
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
    final navHeight = 65.0;
    final bottomPadding =
        navHeight + 24 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
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
                    const SizedBox(height: 16),
                    _buildSearchSection(),
                    const SizedBox(height: 18),
                    _buildTabSection(),
                    const SizedBox(height: 12),
                    _buildJobsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xff3F6CDF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xff3F6CDF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const Spacer(),
          // Jobs Title
          const Text(
            'Jobs',
            style: TextStyle(
              color: Color(0xff070C19),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Notification Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xff070C19),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Find Your',
            style: TextStyle(
              color: Color(0xff070C19),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const Text(
            'Dream Job',
            style: TextStyle(
              color: Color(0xff070C19),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[500], size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Search for job',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xff3F6CDF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab('Recent Jobs', isSelected: true),
          const SizedBox(width: 12),
          _buildTab('Best Matches', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildTab(String text, {required bool isSelected}) {
    return Text(
      text,
      style: TextStyle(
        color: isSelected ? const Color(0xff070C19) : Colors.grey[500],
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildJobsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _allJobs.length,
      itemBuilder: (context, index) {
        final job = _allJobs[index];
        final isSaved = _savedJobIds.contains(job['id']);
        final isFirst = index == 0;

        return _buildJobCard(
          job: job,
          isSaved: isSaved,
          isHighlighted: isFirst,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(job: job),
              ),
            );
          },
          onSave: () => _toggleSaveJob(job['id']),
        );
      },
    );
  }

  Widget _buildJobCard({
    required Map<String, dynamic> job,
    required bool isSaved,
    required bool isHighlighted,
    required VoidCallback onTap,
    required VoidCallback onSave,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Logo and Bookmark
            Row(
              children: [
                // Company Logo
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(job['logo'], color: job['logoColor'], size: 18),
                ),
                const SizedBox(width: 10),
                // Job Title
                Expanded(
                  child: Text(
                    job['title'],
                    style: const TextStyle(
                      color: Color(0xff070C19),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                // Bookmark Icon
                GestureDetector(
                  onTap: onSave,
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: isSaved ? const Color(0xff3F6CDF) : Colors.grey[400],
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  job['location'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Salary
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                Text(
                  job['salary'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Badges and Requirements
            Row(
              children: [
                _buildJobBadge(job['type'], false),
                const SizedBox(width: 6),
                _buildJobBadge(job['location'], false),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    children: [
                      Text(
                        'Requirements',
                        style: TextStyle(
                          color: const Color(0xff3F6CDF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: Color(0xff3F6CDF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobBadge(String text, bool isHighlighted) {
    Color badgeColor;
    if (text == 'Full Time' || text == 'Part Time') {
      badgeColor = const Color(0xff3F6CDF);
    } else if (text == 'Remote' || text.contains('Remote')) {
      badgeColor = const Color(0xff3F6CDF);
    } else {
      badgeColor = const Color(0xff3F6CDF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFloatingBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xff070C19).withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xff3F6CDF) : Colors.white60,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xff3F6CDF) : Colors.white60,
                fontSize: 9,
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
        destination = const ChatBotScreen();
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
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
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
