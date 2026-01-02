import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import 'candidate_details_screen.dart';

class JobApplicantsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsScreen({
    Key? key,
    required this.jobId,
    required this.jobTitle,
  }) : super(key: key);

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _applicants = [];
  Map<String, dynamic>? _jobDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getJobCandidates(widget.jobId);

      print('🔍 Job Applicants Response: $response');
      print('🔍 Response type: ${response.runtimeType}');
      print('🔍 Response keys: ${response.keys}');

      if (response['success'] == true) {
        print('✅ Success is true');

        // Check if 'data' exists and is a Map
        if (response['data'] == null) {
          throw Exception('Response data is null');
        }

        final data = response['data'];
        print('📦 Data: $data');
        print('📦 Data type: ${data.runtimeType}');

        // Safely extract candidates
        dynamic candidatesData = data['candidates'];
        print('👥 Candidates data: $candidatesData');
        print('👥 Candidates type: ${candidatesData.runtimeType}');

        List<dynamic> candidatesList;
        if (candidatesData is List) {
          candidatesList = candidatesData;
        } else if (candidatesData == null) {
          candidatesList = [];
        } else {
          // If it's not a list, wrap it in a list
          candidatesList = [candidatesData];
        }

        setState(() {
          _jobDetails = data['job'];
          _applicants = candidatesList;
          _isLoading = false;
        });

        print('✅ Loaded ${_applicants.length} applicants');
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load applicants';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading applicants: $e');
      print('📚 Stack trace: $stackTrace');
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
          isLoading: _isLoading,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                if (_error != null)
                  Expanded(child: _buildError())
                else if (_applicants.isEmpty && !_isLoading)
                  Expanded(child: _buildEmptyState())
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadApplicants,
                      color: AppColors.primaryGreen,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildJobInfo(),
                          const SizedBox(height: 24),
                          Text(
                            'المتقدمين (${_applicants.length})',
                            style: AppStyles.heading3,
                          ),
                          const SizedBox(height: 16),
                          ..._applicants.map(
                            (applicant) => _buildApplicantCard(
                              applicant as Map<String, dynamic>,
                            ),
                          ),
                        ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المتقدمين', style: AppStyles.heading3),
                const SizedBox(height: 4),
                Text(
                  widget.jobTitle,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo() {
    if (_jobDetails == null) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_jobDetails!['title'] ?? '', style: AppStyles.heading3),
          const SizedBox(height: 12),
          Text(
            _jobDetails!['description'] ?? '',
            style: AppStyles.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    final matchPercentage = applicant['matchPercentage'] ?? 0;
    final name = applicant['name'] ?? 'Unknown';
    final email = applicant['email'] ?? '';
    final phone = applicant['phone'] ?? '';
    final skills = applicant['extractedSkills'] as List? ?? [];
    final appliedAt = applicant['appliedAt'] != null
        ? DateTime.parse(applicant['appliedAt'])
        : null;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewApplicantDetails(applicant),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                    backgroundImage:
                        applicant['photo'] != null &&
                            applicant['photo'].toString().isNotEmpty
                        ? NetworkImage(applicant['photo'])
                        : null,
                    child:
                        applicant['photo'] == null ||
                            applicant['photo'].toString().isEmpty
                        ? Text(
                            name[0].toUpperCase(),
                            style: AppStyles.heading3.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (phone.isNotEmpty)
                          Text(
                            phone,
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getMatchColor(
                            matchPercentage,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$matchPercentage%',
                          style: AppStyles.bodySmall.copyWith(
                            color: _getMatchColor(matchPercentage),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skill.toString(),
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (appliedAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تقدم ${_formatDate(appliedAt)}',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
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
            Text(_error ?? 'خطأ في تحميل البيانات', style: AppStyles.heading3),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'إعادة المحاولة',
              onPressed: _loadApplicants,
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
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text('لا يوجد متقدمين', style: AppStyles.heading2),
            const SizedBox(height: 12),
            Text(
              'لم يتقدم أحد على هذه الوظيفة بعد',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 70) return AppColors.success;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'منذ ${diff.inMinutes} دقيقة';
      }
      return 'منذ ${diff.inHours} ساعة';
    }
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    return 'منذ ${(diff.inDays / 30).floor()} شهر';
  }

  void _viewApplicantDetails(Map<String, dynamic> applicant) {
    // Navigate to applicant details screen
    showDialog(
      context: context,
      builder: (context) => _buildApplicantDetailsDialog(applicant),
    );
  }

  Widget _buildApplicantDetailsDialog(Map<String, dynamic> applicant) {
    final customAnswers = applicant['customAnswers'] as List? ?? [];
    final customQuestions = _jobDetails?['customQuestions'] as List? ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تفاصيل المتقدم', style: AppStyles.heading3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('الاسم', applicant['name'] ?? 'غير متوفر'),
              _buildDetailRow(
                'البريد الإلكتروني',
                applicant['email'] ?? 'غير متوفر',
              ),
              _buildDetailRow('الهاتف', applicant['phone'] ?? 'غير متوفر'),
              _buildDetailRow('المنطقة', applicant['region'] ?? 'غير متوفر'),
              _buildDetailRow('العنوان', applicant['address'] ?? 'غير متوفر'),
              if (applicant['expectedSalary'] != null)
                _buildDetailRow(
                  'الراتب المتوقع',
                  '${applicant['expectedSalary']} جنيه',
                ),
              const SizedBox(height: 16),
              if (customQuestions.isNotEmpty && customAnswers.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'إجابات الأسئلة المخصصة',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  customQuestions.length.clamp(0, customAnswers.length),
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'س: ${customQuestions[index]}',
                          style: AppStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ج: ${customAnswers[index]}',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'عرض السيرة الذاتية',
                      onPressed: () {
                        // TODO: Navigate to CV viewer
                        Navigator.pop(context);
                        _viewCandidateProfile(applicant['id']);
                      },
                      icon: Icons.description,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _viewCandidateProfile(String candidateId) {
    // Navigate to candidate profile screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateDetailsScreen(
          candidateId: candidateId,
          jobId: widget.jobId,
          jobTitle: widget.jobTitle,
        ),
      ),
    );
  }
}
