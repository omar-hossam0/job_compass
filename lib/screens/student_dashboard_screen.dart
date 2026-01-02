import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_buttons.dart';
<<<<<<< HEAD
import '../widgets/job_card.dart';
import 'candidate_chats_screen.dart';
=======
>>>>>>> d893117f2660c36bedd0cd9d7054a36c1ea5fac8

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
  List<Job> _allJobs = []; // الوظائف من صفحة Job Matches
  String? _error;
  int _currentNavIndex = 0;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All Jobs',
    'Product Design',
    'UI/UX Design',
    'Graphic Design',
    'Web Dev',
    'Mobile Dev',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadAllJobs(); // جلب كل الوظائف
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
      // إعادة تحميل الوظائف أيضاً
      _loadAllJobs();
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

  // جلب الوظائف من نفس endpoint صفحة Job Matches
  Future<void> _loadAllJobs() async {
    try {
      final response = await _apiService.get('/student/job-matches');
      if (response['success'] == true) {
        final data = response['data'] as List;
        setState(() {
          _allJobs = data
              .map((j) {
                try {
                  return Job.fromJson(j);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Job>()
              .toList();
          // ترتيب حسب نسبة التطابق
          _allJobs.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        });
      }
    } catch (e) {
      print('Error loading jobs: $e');
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
                          child: _buildSearchBar(),
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryTabs(),
                        const SizedBox(height: 20),
                        _buildPromoBanner(),
                        const SizedBox(height: 24),
                        _buildJobsSection(),
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
    final student = _dashboardData!.student;
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
                  student.name,
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
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ),
          const SizedBox(width: 12),
          // Profile Picture
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/profile');
              _loadDashboard();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image:
                    student.profilePicture != null &&
                        _getImageProvider(student.profilePicture!) != null
                    ? DecorationImage(
                        image: _getImageProvider(student.profilePicture!)!,
                        fit: BoxFit.cover,
                      )
                    : null,
                color: student.profilePicture == null
                    ? const Color(0xFF5B9FED)
                    : null,
              ),
              child: student.profilePicture == null
                  ? Center(
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search_rounded, color: Colors.grey[400], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1D26),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search jobs, skills...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
              Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (_searchController.text.trim().isNotEmpty) {
                        setState(() => _showSuggestions = false);
                        _performSearch(_searchController.text.trim());
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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

                    if (mounted) {
                      setState(() => _showSuggestions = false);
                    }

                    await Future.delayed(const Duration(milliseconds: 50));

                    if (isJob && jobId != null) {
                      if (mounted) {
                        await Navigator.pushNamed(
                          context,
                          '/job-details',
                          arguments: jobId,
                        );
                      }
                    } else {
                      _searchController.text = text ?? '';
                      _performSearch(text ?? '');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: index < _suggestions.length - 1
                          ? Border(bottom: BorderSide(color: Colors.grey[100]!))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B9FED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isJob ? Icons.work_outline : Icons.search,
                            size: 18,
                            color: const Color(0xFF5B9FED),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion['text'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF1A1D26),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              if (suggestion['company'] != null)
                                Text(
                                  suggestion['company'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          isJob ? Icons.arrow_forward_ios : Icons.north_west,
                          size: 14,
                          color: Colors.grey[400],
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

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Row(
                  children: [
                    if (index == 0 && isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B9FED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Career Growth\nMastery',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Boost your career with AI-powered insights',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/skills-analysis'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Explore',
                      style: TextStyle(
                        color: Color(0xFF5B9FED),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection() {
    // استخدام الوظائف من نفس endpoint صفحة Job Matches
    final jobs = _allJobs;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${jobs.isNotEmpty ? jobs.length : 0} results',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D26),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/job-matches'),
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (jobs.isEmpty)
            _buildEmptyJobsState()
          else
            ...jobs.map((job) => _buildModernJobCard(job)),
        ],
      ),
    );
  }

  Widget _buildEmptyJobsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9FED).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.work_off_outlined,
              size: 40,
              color: Color(0xFF5B9FED),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matched jobs yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your CV to get personalized job matches',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/profile');
              _loadDashboard();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Upload CV',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernJobCard(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/job-details', arguments: job.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Company Logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: job.companyLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            job.companyLogo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.business_rounded,
                              color: Color(0xFF5B9FED),
                              size: 26,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.business_rounded,
                          color: Color(0xFF5B9FED),
                          size: 26,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D26),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            job.company,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              job.location ?? 'Remote',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '\$${(job.salary / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                Text(
                  '/Year',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${job.matchScore.toInt()}% Match',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5B9FED),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ...job.employmentType
                    .take(2)
                    .map<Widget>(
                      (type) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1A1D26),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
            await Navigator.pushNamed(context, '/job-matches');
            // Reset to home when returning
            setState(() => _currentNavIndex = 0);
          }),
<<<<<<< HEAD
          _buildNavItemIcon(Icons.chat_bubble_outline_rounded, 2, () {
            setState(() => _currentNavIndex = 2);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CandidateChatsScreen()),
=======
          _buildNavItem(Icons.bookmark_outline_rounded, 'Saved', 2, () {
            setState(() => _currentNavIndex = 2);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved jobs coming soon')),
>>>>>>> d893117f2660c36bedd0cd9d7054a36c1ea5fac8
            );
          }),
          _buildNavItem(Icons.person_outline_rounded, 'Profile', 3, () async {
            setState(() => _currentNavIndex = 3);
            await Navigator.pushNamed(context, '/profile');
            _loadDashboard();
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

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF5B9FED) : Colors.grey[400],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
