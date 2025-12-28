import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/job_card.dart';

class JobMatchesScreen extends StatefulWidget {
  const JobMatchesScreen({Key? key}) : super(key: key);

  @override
  State<JobMatchesScreen> createState() => _JobMatchesScreenState();
}

class _JobMatchesScreenState extends State<JobMatchesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Job> _jobs = [];
  String? _error;
  String _sortBy = 'match';

  @override
  void initState() {
    super.initState();
    _loadJobMatches();
  }

  Future<void> _loadJobMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all jobs from /jobs endpoint (returns active jobs for students)
      final response = await _apiService.get('/jobs');

      print('📥 Jobs API Response: $response');

      if (response['success'] == true) {
        print('✅ Success! Data type: ${response['data'].runtimeType}');
        print('📊 Jobs count: ${(response['data'] as List).length}');

        final jobsList = (response['data'] as List)
            .map((j) {
              try {
                return Job.fromJson(j);
              } catch (e) {
                print('❌ Error parsing job: $e');
                print('Job data: $j');
                return null;
              }
            })
            .whereType<Job>() // Filter out nulls
            .toList();

        print('✅ Parsed ${jobsList.length} jobs successfully');

        setState(() {
          _jobs = jobsList;
          _sortJobs();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load jobs';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Load jobs error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _sortJobs() {
    switch (_sortBy) {
      case 'match':
        _jobs.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        break;
      case 'salary':
        _jobs.sort((a, b) => b.salary.compareTo(a.salary));
        break;
      case 'date':
        _jobs.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        break;
    }
  }

  int _calculateAvgMatch() {
    if (_jobs.isEmpty) return 0;
    final total = _jobs.fold(0.0, (sum, job) => sum + job.matchScore);
    return (total / _jobs.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: LoadingOverlay(
          isLoading: _isLoading && _jobs.isEmpty,
          child: SafeArea(
            child: _error != null
                ? _buildError()
                : Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadJobMatches,
                          color: AppColors.primaryGreen,
                          child: _jobs.isEmpty
                              ? _buildEmptyState()
                              : SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildHeader(),
                                        const SizedBox(height: 24),
                                        _buildSortOptions(),
                                        const SizedBox(height: 24),
                                        ..._jobs.map(
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
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load job matches', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadJobMatches,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text('No Job Matches Yet', style: AppStyles.heading2),
            const SizedBox(height: 12),
            Text(
              'Upload your CV to get personalized job recommendations',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Upload CV',
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: Icons.upload_file,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButtonCircular(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white.withOpacity(0.3),
            iconColor: AppColors.textPrimary,
          ),
          const SizedBox(width: 16),
          Text('Job Matches', style: AppStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.primaryTeal],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.work, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Matches', style: AppStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '${_jobs.length}',
                  style: AppStyles.heading1.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Avg Match', style: AppStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                '${_calculateAvgMatch()}%',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSortChip('Best Match', 'match', Icons.stars),
          const SizedBox(width: 12),
          _buildSortChip('Highest Salary', 'salary', Icons.attach_money),
          const SizedBox(width: 12),
          _buildSortChip('Most Recent', 'date', Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
          _sortJobs();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryTeal],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
