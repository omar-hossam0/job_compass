import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

class SkillAnalysisScreen extends StatefulWidget {
  const SkillAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<SkillAnalysisScreen> createState() => _SkillAnalysisScreenState();
}

class _SkillAnalysisScreenState extends State<SkillAnalysisScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoadingJobs = true;
  List<Job> _jobs = [];
  String? _jobsError;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoadingJobs = true;
      _jobsError = null;
    });

    try {
      final response = await _apiService.get('/jobs');
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _jobs = (response['data'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
          _isLoadingJobs = false;
        });
      } else {
        setState(() {
          _jobsError = response['message'] ?? 'Failed to load jobs';
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      setState(() {
        _jobsError = e.toString();
        _isLoadingJobs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: LoadingOverlay(
                  isLoading: _isLoadingJobs,
                  child: _jobsError != null
                      ? _buildJobsError()
                      : RefreshIndicator(
                          onRefresh: _loadJobs,
                          color: AppColors.primaryGreen,
                          child: _jobs.isEmpty
                              ? _buildNoJobsFound()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: _jobs.length,
                                  itemBuilder: (context, index) {
                                    return _buildJobCardForAnalysis(_jobs[index]);
                                  },
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
          Text('Analyze Jobs', style: AppStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildJobsError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load jobs', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              _jobsError ?? 'Unknown error',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadJobs,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoJobsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('No jobs available', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'There are no jobs posted yet. Check back later!',
              style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCardForAnalysis(Job job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: job.companyLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            job.companyLogo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.business,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : Icon(Icons.business, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: AppStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.employmentType.isNotEmpty
                        ? job.employmentType.first
                        : 'Full-time',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (job.requiredSkills.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.requiredSkills.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      skill,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/job-analysis',
                    arguments: {'jobId': job.id, 'jobTitle': job.title},
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 20),
                label: const Text('Analyze My CV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
