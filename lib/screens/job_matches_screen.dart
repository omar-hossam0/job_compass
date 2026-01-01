import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
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
  bool _hasCv = true;

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
      // Use fast mode to avoid long waits on initial load
      final response = await _apiService.get('/student/job-matches');
      final hasCv = response['hasCv'] ?? true;

      print('📥 Job Matches API Response: $response');

      if (response['success'] == true) {
        final data = response['data'];

        // Check if user has uploaded CV
        if (hasCv == false) {
          print('⚠️ No CV uploaded - showing empty state');
          setState(() {
            _hasCv = false;
            _jobs = [];
            _isLoading = false;
          });
          return;
        }

        // Persist CV state even when jobs are empty
        _hasCv = hasCv;

        print('✅ Success! Data type: ${data.runtimeType}');
        print('📊 Jobs count: ${(data as List).length}');

        final jobsList = data
            .map((j) {
              try {
                return Job.fromJson(j);
              } catch (e) {
                print('❌ Error parsing job: $e');
                print('Job data: $j');
                return null;
              }
            })
            .whereType<Job>()
            .toList();

        print('✅ Parsed ${jobsList.length} jobs successfully');
        if (jobsList.isNotEmpty) {
          print(
            '🏆 Top match: ${jobsList.first.title} - ${jobsList.first.matchScore}%',
          );
        }

        setState(() {
          _jobs = jobsList;
          _sortJobs();
          _hasCv = hasCv;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load job matches';
          _hasCv = hasCv;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Load job matches error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _hasCv = true;
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
      backgroundColor: const Color(0xFFF8F9FD),
      body: LoadingOverlay(
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
                        color: const Color(0xFF5B9FED),
                        child: _jobs.isEmpty
                            ? _buildEmptyState()
                            : SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
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
    final title = _hasCv ? 'No matched jobs yet' : 'No CV Found';
    final subtitle = _hasCv
        ? 'Upload your CV to get personalized job matches'
        : 'Upload your CV to get personalized job recommendations';
    final icon = _hasCv ? Icons.work_off_outlined : Icons.upload_file;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FED).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 50, color: const Color(0xFF5B9FED)),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _hasCv
                    ? _loadJobMatches
                    : () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _hasCv ? 'Upload CV' : 'Upload CV',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
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
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D26)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Job Matches',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Matches',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_jobs.length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Avg Match',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_calculateAvgMatch()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B9FED),
                    fontWeight: FontWeight.bold,
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF5B9FED), Color(0xFF7BB8F7)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[200]!),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5B9FED).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
