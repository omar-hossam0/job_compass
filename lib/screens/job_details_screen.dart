import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/skill_widgets.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Job? _job;
  String? _error;
  bool _isSaved = false;
  bool _hasApplied = false; // Track if user has applied

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getJobDetails(widget.jobId);
      print('🔍 Job Details Response: $response');

      // Extract job data from response
      final jobData = response['data'] ?? response;
      print('📦 Job Data: $jobData');

      // Check if user has applied (look for current user in applicants)
      final applicants = jobData['applicants'] as List?;
      _hasApplied = applicants != null && applicants.isNotEmpty;

      setState(() {
        _job = Job.fromJson(jobData);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading job details: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _isLoading && _job == null,
        child: SafeArea(
          child: _error != null
              ? _buildError()
              : _job == null
              ? const SizedBox()
              : Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildJobHeader(),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDescription(),
                                  const SizedBox(height: 24),
                                  _buildRequirements(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(),
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
            Text('Failed to load job details', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadJobDetails,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary,
          ),
          const Spacer(),
          Text(
            _job!.company,
            style: AppStyles.heading3.copyWith(color: AppColors.textPrimary),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppColors.primaryTeal : AppColors.textSecondary,
            ),
            onPressed: () => setState(() => _isSaved = !_isSaved),
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          // Company Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _job!.companyLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _job!.companyLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.business,
                          color: AppColors.primaryTeal,
                          size: 40,
                        );
                      },
                    ),
                  )
                : Icon(Icons.business, color: AppColors.primaryTeal, size: 40),
          ),
          const SizedBox(height: 16),
          // Job Title
          Text(
            _job!.title,
            style: AppStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _job!.location,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Job Type and Salary
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Job Type Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _job!.employmentType.isNotEmpty
                      ? _job!.employmentType.first
                      : 'Full-Time',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Salary
              Text(
                _job!.salary > 0
                    ? '\$${(_job!.salary / 1000).toStringAsFixed(0)}k${_job!.salaryPeriod}'
                    : 'Negotiable',
                style: AppStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Descriptions',
          style: AppStyles.heading3.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _job!.description,
          style: AppStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: AppStyles.heading3.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        // Display required skills as bullet points
        ..._job!.requiredSkills.map((skill) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    skill,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Analysis Button
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/job-analysis',
                      arguments: {
                        'jobId': widget.jobId,
                        'jobTitle': _job?.title,
                      },
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analysis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: BorderSide(color: AppColors.primaryTeal, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Apply or Cancel Button
            Expanded(
              child: SizedBox(
                height: 56,
                child: _hasApplied
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('إلغاء التقديم'),
                              content: const Text(
                                'هل أنت متأكد من إلغاء التقديم على هذه الوظيفة؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('لا'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('نعم، إلغاء'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            setState(() => _isLoading = true);

                            try {
                              final response = await _apiService
                                  .cancelApplication(widget.jobId);

                              if (mounted) {
                                setState(() => _isLoading = false);

                                if (response['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response['message'] ??
                                            'تم إلغاء التقديم بنجاح',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  // Reload job details to update UI
                                  _loadJobDetails();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response['message'] ??
                                            'فشل إلغاء التقديم',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ: ${e.toString()}'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('إلغاء التقديم'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          // Navigate to application form
                          final result = await Navigator.pushNamed(
                            context,
                            '/job-application',
                            arguments: {
                              'jobId': widget.jobId,
                              'jobTitle': _job?.title ?? 'Job',
                              'customQuestions': _job?.customQuestions ?? [],
                            },
                          );

                          // If application was successful, reload details
                          if (result == true && mounted) {
                            _loadJobDetails(); // Reload to update button state
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'تقديم الطلب',
                          style: AppStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
