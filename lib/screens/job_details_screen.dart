import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
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
      setState(() {
        _job = Job.fromJson(response);
        _isLoading = false;
      });
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
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildJobHeader(),
                                    const SizedBox(height: 24),
                                    _buildMatchScore(),
                                    const SizedBox(height: 24),
                                    _buildJobInfo(),
                                    const SizedBox(height: 24),
                                    _buildDescription(),
                                    const SizedBox(height: 24),
                                    _buildRequiredSkills(),
                                    const SizedBox(height: 24),
                                    _buildMissingSkills(),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildBottomActions(),
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
            Text('Failed to load job details', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(_error ?? 'Unknown error', style: AppStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Retry', onPressed: _loadJobDetails, icon: Icons.refresh),
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
          Text('Job Details', style: AppStyles.heading2),
          const Spacer(),
          IconButtonCircular(
            icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
            onPressed: () => setState(() => _isSaved = !_isSaved),
            backgroundColor: Colors.white.withOpacity(0.3),
            iconColor: _isSaved ? AppColors.primaryGreen : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _job!.companyLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(_job!.companyLogo!, fit: BoxFit.cover),
                  )
                : Icon(Icons.business, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 16),
          Text(_job!.title, style: AppStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_job!.company, style: AppStyles.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _job!.employmentType.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(type, style: AppStyles.bodySmall.copyWith(color: AppColors.primaryGreen)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchScore() {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: _buildInfoColumn('Match Score', '${_job!.matchScore.toInt()}%', Icons.show_chart, AppColors.success),
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildInfoColumn('Salary', '\$${(_job!.salary / 1000).toStringAsFixed(0)}k${_job!.salaryPeriod}', Icons.attach_money, AppColors.primaryGreen),
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildInfoColumn('Experience', '${_job!.experienceYears} Years', Icons.work_history, AppColors.info),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: AppStyles.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildJobInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Job Information', style: AppStyles.heading3),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              _buildInfoRow(Icons.location_on, 'Location', _job!.location),
              const Divider(height: 24),
              _buildInfoRow(Icons.calendar_today, 'Posted', _formatDate(_job!.postedAt)),
              const Divider(height: 24),
              _buildInfoRow(Icons.people, 'Applicants', '${_job!.applicantsCount}+'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppStyles.bodyMedium),
        const Spacer(),
        Text(value, style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppStyles.heading3),
        const SizedBox(height: 16),
        GlassCard(
          child: Text(_job!.description, style: AppStyles.bodyMedium.copyWith(height: 1.6)),
        ),
      ],
    );
  }

  Widget _buildRequiredSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Required Skills', style: AppStyles.heading3),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/skill-gap', arguments: widget.jobId),
              child: Text('View Gap Analysis', style: AppStyles.bodySmall.copyWith(color: AppColors.primaryGreen)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _job!.requiredSkills.map((skill) => SkillChip(label: skill)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingSkills() {
    if (_job!.missingSkillsCount == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Missing Skills', style: AppStyles.heading3),
        const SizedBox(height: 16),
        GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber, color: AppColors.warning, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_job!.missingSkillsCount} skills to improve', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Check learning path for recommendations', style: AppStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'View Gap',
                onPressed: () => Navigator.pushNamed(context, '/skill-gap', arguments: widget.jobId),
                icon: Icons.analytics_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Apply Now',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application submitted!'), backgroundColor: AppColors.success),
                  );
                },
                icon: Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}
