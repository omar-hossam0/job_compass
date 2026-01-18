import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_candidate_match.dart';
import '../models/hr_dashboard.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_buttons.dart';
import 'hr_chats_screen.dart';

class HRDashboardScreen extends StatefulWidget {
  const HRDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HRDashboardScreen> createState() => _HRDashboardScreenState();
}

class _HRDashboardScreenState extends State<HRDashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  HRDashboardData? _dashboardData;
  String? _error;
  int _currentNavIndex = 0;
  bool _isMatching = false;
  String? _matchingJobId;
  List<HRCandidateMatch> _matches = [];
  String? _matchesJobTitle;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _findMatchesForJob(Map<String, dynamic> job) async {
    final jobId = (job['_id'] ?? job['id'] ?? '').toString();
    if (jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job ID not found for this posting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isMatching = true;
      _matchingJobId = jobId;
    });

    try {
      final response = await _apiService.matchCVsToJob(jobId);
      if (response['success'] == true && response['data'] != null) {
        final matches = (response['data'] as List)
            .map((item) => HRCandidateMatch.fromJson(item))
            .toList();
        if (!mounted) return;
        setState(() {
          _matches = matches;
          _matchesJobTitle = (job['title'] ?? response['jobTitle'] ?? 'Job')
              .toString();
        });

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _buildMatchesSheet(),
        );

        if (mounted) {
          setState(() {
            _matches = [];
            _matchesJobTitle = null;
          });
        }
      } else {
        final message = response['message'] ?? 'Failed to fetch matches';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finding matches: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMatching = false;
          _matchingJobId = null;
        });
      }
    }
  }

  void _handleQuickFindMatches() {
    final jobs = _dashboardData?.recentJobs ?? [];
    if (jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No jobs available to match yet. Post a job first!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    _findMatchesForJob(jobs.first);
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getHRDashboard();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _dashboardData = HRDashboardData.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load dashboard';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: LoadingOverlay(
        isLoading: _isLoading && _dashboardData == null,
        child: SafeArea(
          child: _error != null
              ? _buildError()
              : _dashboardData == null
              ? const SizedBox()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  color: AppColors.primaryGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildStatsCards(),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildQuickActions(),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildRecentJobs(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load dashboard', style: AppStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Retry',
            onPressed: _loadDashboard,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning,';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon,';
    } else if (hour >= 17) {
      greeting = 'Good Evening,';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dashboardData?.companyName ?? 'Company',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Notification Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF1A1D26),
                    size: 24,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5B9FED),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/hr/notifications');
              },
            ),
          ),
          const SizedBox(width: 12),
          // Profile/Settings Icon
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/hr/settings');
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF5B9FED),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (_dashboardData?.companyName ?? 'C').isNotEmpty
                      ? (_dashboardData?.companyName ?? 'C')[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Jobs',
            _dashboardData?.activeJobsCount.toString() ?? '0',
            Icons.work_rounded,
            const Color(0xFF5B9FED),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Candidates',
            _dashboardData?.totalCandidatesCount.toString() ?? '0',
            Icons.people_rounded,
            const Color(0xFF6BCB77),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B9FED), Color(0xFF4A8FDD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B9FED).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/hr/post-job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5B9FED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Post Job',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/hr/jobs'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View Jobs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isMatching ? null : () => _handleQuickFindMatches(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.white, width: 1.5),
                elevation: 0,
              ),
              icon: _isMatching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.manage_search_rounded, size: 20),
              label: Text(
                _isMatching ? 'Finding...' : 'Find Best Matches',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJobs() {
    final jobs = _dashboardData?.recentJobs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            if (jobs.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/hr/jobs'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF5B9FED),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (jobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No jobs posted yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Post your first job to get started',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...jobs
              .take(3)
              .map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildJobItem(job),
                ),
              ),
      ],
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gradientStart,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/hr/job-details',
          arguments: job['_id'] ?? job['id'],
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job['title'] ?? 'Job Title',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D26),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: job['status'] == 'active'
                          ? AppColors.primaryBlue.withOpacity(0.12)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job['status']?.toUpperCase() ?? 'ACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        color: job['status'] == 'active'
                            ? AppColors.primaryBlue
                            : Colors.grey[700],
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job['description'] ?? '${job['title']} ${job['title']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${job['applicantsCount'] ?? 0} applicants',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.military_tech_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    job['experienceLevel'] ?? 'Entry Level',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag(job['category'] ?? 'mobile'),
                  if (job['employmentType'] != null)
                    _buildTag(job['employmentType']),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/hr/job-details',
                        arguments: job['_id'] ?? job['id'],
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('View Job'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1D26),
                        side: const BorderSide(
                          color: Color(0xFF1A1D26),
                          width: 1.4,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isMatching && _matchingJobId == (job['_id'] ?? job['id']).toString()
                          ? null
                          : () => _findMatchesForJob(job),
                      icon: _isMatching &&
                              _matchingJobId == (job['_id'] ?? job['id']).toString()
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.manage_search_rounded),
                      label: Text(
                        _isMatching &&
                                _matchingJobId == (job['_id'] ?? job['id']).toString()
                            ? 'Finding...'
                            : 'Find Matches',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFBCDFC2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2D5F3D),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', 0, () {
            setState(() => _currentNavIndex = 0);
          }),
          _buildNavItem(Icons.work_outline_rounded, 'Jobs', 1, () async {
            setState(() => _currentNavIndex = 1);
            await Navigator.pushNamed(context, '/hr/jobs');
            setState(() => _currentNavIndex = 0);
          }),
          _buildNavItem(
            Icons.chat_bubble_outline_rounded,
            'Chats',
            2,
            () async {
              setState(() => _currentNavIndex = 2);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HRChatsScreen()),
              );
              setState(() => _currentNavIndex = 0);
            },
          ),
          _buildNavItem(Icons.notifications_outlined, 'Alerts', 3, () async {
            setState(() => _currentNavIndex = 3);
            await Navigator.pushNamed(context, '/hr/notifications');
            setState(() => _currentNavIndex = 0);
          }),
          _buildNavItem(Icons.settings_outlined, 'Settings', 4, () async {
            setState(() => _currentNavIndex = 4);
            await Navigator.pushNamed(context, '/hr/settings');
            setState(() => _currentNavIndex = 0);
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    final isActive = _currentNavIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isActive
                    ? null
                    : Border.all(color: Colors.grey[200]!, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? const Color(0xFF5B9FED).withOpacity(0.25)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isActive ? 16 : 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF5B6770),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF5B9FED) : const Color(0xFF5B6770),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F7FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top CV Matches',
                            style: AppStyles.heading2.copyWith(
                              color: const Color(0xFF0D47A1),
                            ),
                          ),
                          if (_matchesJobTitle != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'for "${_matchesJobTitle}"',
                              style: AppStyles.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _matches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_outlined,
                                size: 54,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No matching CVs found yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D26),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ensure candidates have uploaded their CVs and that job descriptions include detailed skills.',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        itemCount: _matches.length,
                        itemBuilder: (context, index) =>
                            _buildMatchCard(_matches[index], index),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(HRCandidateMatch candidate, int index) {
    // Enhanced color coding based on match score
    final matchColor = candidate.matchScore >= 75
        ? const Color(0xFF2E7D32) // Excellent match - dark green
        : candidate.matchScore >= 60
            ? const Color(0xFF43A047) // Good match - green
            : candidate.matchScore >= 45
                ? const Color(0xFFF9A825) // Fair match - amber
                : const Color(0xFFE53935); // Poor match - red

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    if (candidate.phone != null && candidate.phone!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          candidate.phone!,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: matchColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          candidate.matchScore >= 75
                              ? Icons.verified_rounded
                              : candidate.matchScore >= 60
                                  ? Icons.check_circle_outline_rounded
                                  : candidate.matchScore >= 45
                                      ? Icons.info_outline_rounded
                                      : Icons.warning_amber_rounded,
                          size: 16,
                          color: matchColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${candidate.matchScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: matchColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    candidate.matchScore >= 75
                        ? 'Excellent Match'
                        : candidate.matchScore >= 60
                            ? 'Good Match'
                            : candidate.matchScore >= 45
                                ? 'Fair Match'
                                : 'Low Match',
                    style: TextStyle(
                      fontSize: 11,
                      color: matchColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (candidate.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: candidate.skills.take(6).map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D47A1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (candidate.resumePreview != null &&
              candidate.resumePreview!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                candidate.resumePreview!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/hr/candidate-details',
                    arguments: candidate.id,
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D47A1),
                    side: const BorderSide(
                      color: Color(0xFF0D47A1),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/hr/candidate-details',
                  arguments: candidate.id,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Review CV',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
