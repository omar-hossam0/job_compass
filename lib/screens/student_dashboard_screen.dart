import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/job_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;
  DashboardData? _dashboardData;
  String? _error;
  int _currentNavIndex = 0;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final response = await _apiService.getJobSuggestions(query);
      if (response['success'] && mounted) {
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(
            (response['data'] ?? []).map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      // Silently fail for suggestions
    }
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getStudentDashboard();
      print(
        '📸 Dashboard response: ${response['data']?['student']?['profilePicture'] != null ? "Has profilePicture" : "No profilePicture"}',
      );
      if (response['data']?['student']?['profilePicture'] != null) {
        final img = response['data']['student']['profilePicture'].toString();
        print(
          '📸 Profile picture type: ${img.substring(0, img.length > 50 ? 50 : img.length)}...',
        );
      }
      setState(() {
        _dashboardData = DashboardData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  ImageProvider? _getImageProvider(String imageData) {
    try {
      // Check if it's a base64 data URI
      if (imageData.startsWith('data:image')) {
        final base64String = imageData.split(',')[1];
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      }
      // Otherwise treat as URL
      return NetworkImage(imageData);
    } catch (e) {
      print('Error loading image: $e');
      return null;
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
                            const SizedBox(height: 24),
                            _buildSearchBar(),
                            const SizedBox(height: 24),
                            _buildStatsCards(),
                            const SizedBox(height: 24),
                            _buildQuickActions(),
                            const SizedBox(height: 24),
                            _buildTopMatchedJobs(),
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
    final student = _dashboardData!.student;

    return Row(
      children: [
        // Profile Picture
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen,
              image:
                  student.profilePicture != null &&
                      _getImageProvider(student.profilePicture!) != null
                  ? DecorationImage(
                      image: _getImageProvider(student.profilePicture!)!,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: student.profilePicture == null
                ? Center(
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : 'U',
                      style: AppStyles.heading2.copyWith(color: Colors.white),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: AppStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Let's Find\nYour Next Future.",
                style: AppStyles.heading1.copyWith(
                  fontSize: 28,
                  color: AppColors.textLight,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Notification Icon
        IconButtonCircular(
          icon: Icons.notifications_outlined,
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
          backgroundColor: Colors.white.withOpacity(0.3),
          iconColor: Colors.white,
          size: 48,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search jobs, skills, locations...',
                    hintStyle: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() => _showSuggestions = false);
                      _performSearch(value.trim());
                    }
                  },
                  onTap: () {
                    if (_suggestions.isNotEmpty) {
                      setState(() => _showSuggestions = true);
                    }
                  },
                ),
              ),
              IconButtonCircular(
                icon: Icons.search,
                onPressed: () {
                  if (_searchController.text.trim().isNotEmpty) {
                    setState(() => _showSuggestions = false);
                    _performSearch(_searchController.text.trim());
                  }
                },
                backgroundColor: AppColors.primaryGreen,
                size: 40,
              ),
            ],
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                final isJob = suggestion['type'] == 'job';

                return InkWell(
                  onTap: () async {
                    final jobId = suggestion['jobId'];
                    final text = suggestion['text'];
                    final isJob = suggestion['type'] == 'job';

                    // Hide suggestions immediately
                    if (mounted) {
                      setState(() => _showSuggestions = false);
                    }

                    // Small delay to ensure UI updates
                    await Future.delayed(const Duration(milliseconds: 50));

                    if (isJob && jobId != null) {
                      // Navigate directly to job details
                      if (mounted) {
                        await Navigator.pushNamed(
                          context,
                          '/job-details',
                          arguments: jobId,
                        );
                      }
                    } else {
                      // Perform search
                      _searchController.text = text ?? '';
                      _performSearch(text ?? '');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: index < _suggestions.length - 1
                          ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isJob ? Icons.work_outline : Icons.search,
                          size: 18,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion['text'] ?? '',
                                style: AppStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (suggestion['company'] != null)
                                Text(
                                  suggestion['company'],
                                  style: AppStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          isJob ? Icons.arrow_forward_ios : Icons.north_west,
                          size: 14,
                          color: AppColors.textSecondary,
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

  Future<void> _performSearch(String query) async {
    try {
      final response = await _apiService.searchJobs(query);
      if (response['success'] && mounted) {
        // Navigate to search results screen
        Navigator.pushNamed(
          context,
          '/search-results',
          arguments: {
            'query': query,
            'results': response['data'],
            'count': response['count'],
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatsCards() {
    final student = _dashboardData!.student;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Profile Completion',
            '${student.profileCompletion}%',
            Icons.person_outline,
            student.profileCompletion / 100,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Skill Match',
            '${student.skillMatchScore.toInt()}%',
            Icons.psychology_outlined,
            student.skillMatchScore / 100,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    double progress,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppStyles.heading3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Upload CV',
                Icons.upload_file,
                () async {
                  await Navigator.pushNamed(context, '/profile');
                  _loadDashboard();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Analyze Skills',
                Icons.analytics_outlined,
                () => Navigator.pushNamed(context, '/skills-analysis'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Learning Path',
                Icons.school_outlined,
                () => Navigator.pushNamed(context, '/learning-path'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Job Matches',
                Icons.work_outline,
                () => Navigator.pushNamed(context, '/job-matches'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Ask AI Assistant',
                Icons.smart_toy_rounded,
                () => Navigator.pushNamed(context, '/chatbot'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()), // Empty space for symmetry
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopMatchedJobs() {
    final jobs = _dashboardData!.topMatchedJobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Matched Jobs', style: AppStyles.heading3),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/job-matches'),
              child: Text(
                'View All',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (jobs.isEmpty)
          GlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text('No matched jobs yet', style: AppStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your CV to get started',
                      style: AppStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...jobs.map(
            (job) => JobCard(
              job: job,
              onTap: () => Navigator.pushNamed(
                context,
                '/job-details',
                arguments: job.id,
              ),
            ),
          ),
      ],
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
            Navigator.pushNamed(context, '/job-matches');
          }),
          _buildNavItemIcon(Icons.bookmark_outline_rounded, 2, () {
            setState(() => _currentNavIndex = 2);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved jobs screen coming soon')),
            );
          }),
          _buildNavItemIcon(Icons.person_outline_rounded, 3, () async {
            setState(() => _currentNavIndex = 3);
            await Navigator.pushNamed(context, '/profile');
            _loadDashboard();
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
          // Inactive state: transparent background (no white tray behind icons)
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          // Keep a subtle white border only for active state if desired
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
