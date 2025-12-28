import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_dashboard.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboard();
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
      body: GradientBackground(
        child: LoadingOverlay(
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildStatsCards(),
                            const SizedBox(height: 24),
                            _buildQuickActions(),
                            const SizedBox(height: 24),
                            _buildRecentJobs(),
                          ],
                        ),
                      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back! 👋',
          style: AppStyles.heading3.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          _dashboardData?.companyName ?? 'Company',
          style: AppStyles.heading1.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Candidates',
            _dashboardData?.totalCandidatesCount.toString() ?? '0',
            Icons.people_rounded,
            AppColors.primaryBlue,
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
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: AppStyles.heading1.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppStyles.heading2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Post Job',
                onPressed: () => Navigator.pushNamed(context, '/hr/post-job'),
                icon: Icons.add_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/hr/jobs'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_rounded),
                    const SizedBox(width: 8),
                    Text('View Jobs', style: AppStyles.buttonText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
            Text('Recent Jobs', style: AppStyles.heading2),
            if (jobs.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/hr/jobs'),
                child: Text(
                  'View All',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (jobs.isEmpty)
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text('No jobs posted yet', style: AppStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Post your first job to get started',
                      style: AppStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
    return GlassCard(
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/hr/job-details',
          arguments: job['_id'] ?? job['id'],
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.work_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? 'Job Title',
                      style: AppStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job['applicantsCount'] ?? 0} applicants',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: job['status'] == 'active'
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.textSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job['status'] ?? 'active',
                  style: AppStyles.bodySmall.copyWith(
                    color: job['status'] == 'active'
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItemIcon(Icons.home_rounded, 0, () {
            setState(() => _currentNavIndex = 0);
          }),
          _buildNavItemIcon(Icons.work_outline_rounded, 1, () {
            setState(() => _currentNavIndex = 1);
            Navigator.pushNamed(context, '/hr/jobs');
          }),
          _buildNavItemIcon(Icons.notifications_outlined, 2, () {
            setState(() => _currentNavIndex = 2);
            Navigator.pushNamed(context, '/hr/notifications');
          }),
          _buildNavItemIcon(Icons.settings_outlined, 3, () {
            setState(() => _currentNavIndex = 3);
            Navigator.pushNamed(context, '/hr/settings');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItemIcon(IconData icon, int index, VoidCallback onTap) {
    final isActive = _currentNavIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 62,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          // Inactive state: transparent background (remove white circles)
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isActive
              ? Border.all(color: Colors.white.withOpacity(0.6), width: 0.6)
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}
