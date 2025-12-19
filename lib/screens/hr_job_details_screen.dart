import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_job.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

class HRJobDetailsScreen extends StatefulWidget {
  final String jobId;

  const HRJobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<HRJobDetailsScreen> createState() => _HRJobDetailsScreenState();
}

class _HRJobDetailsScreenState extends State<HRJobDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  HRJob? _job;
  String? _error;

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
      final response = await _apiService.getJobById(widget.jobId);
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _job = HRJob.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load job details';
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

  Future<void> _closeJob() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Job'),
        content: const Text('Are you sure you want to close this job posting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close Job'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _apiService.closeJob(widget.jobId);
      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job closed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadJobDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to close job'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildError()
                    : _buildJobDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Job Details',
              style: AppStyles.heading1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
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
          ElevatedButton.icon(
            onPressed: _loadJobDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails() {
    if (_job == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 20),
          _buildJobDescription(),
          const SizedBox(height: 20),
          _buildRequiredSkills(),
          const SizedBox(height: 20),
          _buildJobInfo(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _job!.title,
                    style: AppStyles.heading1.copyWith(fontSize: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _job!.status == 'active'
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.textSecondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _job!.status.toUpperCase(),
                    style: AppStyles.bodySmall.copyWith(
                      color: _job!.status == 'active'
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_job!.applicantsCount} Applicants',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDescription() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Description', style: AppStyles.heading3),
            const SizedBox(height: 12),
            Text(
              _job!.description,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredSkills() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Required Skills', style: AppStyles.heading3),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _job!.requiredSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfo() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Information', style: AppStyles.heading3),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.emoji_events_outlined,
              'Experience Level',
              _job!.experienceLevel,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Posted',
              _formatDate(_job!.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'View Candidates',
          onPressed: () => Navigator.pushNamed(
            context,
            '/hr/candidates',
            arguments: widget.jobId,
          ),
          icon: Icons.people_rounded,
        ),
        const SizedBox(height: 12),
        if (_job!.status == 'active')
          OutlinedButton.icon(
            onPressed: _closeJob,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Close Job'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
