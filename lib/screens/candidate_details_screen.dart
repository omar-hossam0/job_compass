import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_candidate.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import 'chat_screen.dart';

class CandidateDetailsScreen extends StatefulWidget {
  final String candidateId;
  final String? jobId;
  final String? jobTitle;

  const CandidateDetailsScreen({
    Key? key,
    required this.candidateId,
    this.jobId,
    this.jobTitle,
  }) : super(key: key);

  @override
  State<CandidateDetailsScreen> createState() => _CandidateDetailsScreenState();
}

class _CandidateDetailsScreenState extends State<CandidateDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  HRCandidate? _candidate;
  String? _error;
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCandidateDetails();
  }

  Future<void> _loadCandidateDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getCandidateDetails(
        widget.candidateId,
        jobId: widget.jobId,
      );
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _candidate = HRCandidate.fromJson(response['data']);
          _isSaved = response['isSaved'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load candidate details';
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

  Future<void> _toggleSaveCandidate() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      if (_isSaved) {
        // Unsave
        final response = await _apiService.unsaveCandidate(widget.candidateId);
        if (mounted) {
          if (response['success'] == true) {
            setState(() => _isSaved = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Candidate removed from saved'),
                backgroundColor: AppColors.textSecondary,
              ),
            );
          }
        }
      } else {
        // Save
        final response = await _apiService.saveCandidate(
          widget.candidateId,
          jobId: widget.jobId,
        );
        if (mounted) {
          if (response['success'] == true) {
            setState(() => _isSaved = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Candidate saved successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveCandidate() async {
    await _toggleSaveCandidate();
  }

  void _contactCandidate() {
    // Show contact dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Candidate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${_candidate?.email ?? 'N/A'}'),
            if (_candidate?.phone != null) ...[
              const SizedBox(height: 8),
              Text('Phone: ${_candidate!.phone}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                    : _buildCandidateDetails(),
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
          Text('Candidate Details', style: AppStyles.heading1),
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
          Text('Failed to load candidate', style: AppStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCandidateDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateDetails() {
    if (_candidate == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCandidateHeader(),
          const SizedBox(height: 20),
          _buildContactInfo(),
          const SizedBox(height: 20),
          _buildMatchInfo(),
          const SizedBox(height: 20),
          _buildExtractedSkills(),
          if (_candidate!.screeningAnswers.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildScreeningAnswers(),
          ],
          if (_candidate!.cvUrl != null && _candidate!.cvUrl!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildCVDownload(),
          ],
          if (_candidate!.cvText != null && _candidate!.cvText!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildCVPreview(),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCandidateHeader() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _candidate!.profilePicture != null
                  ? NetworkImage(_candidate!.profilePicture!)
                  : null,
              backgroundColor: AppColors.primaryGreen,
              child: _candidate!.profilePicture == null
                  ? Text(
                      _candidate!.name.isNotEmpty
                          ? _candidate!.name[0].toUpperCase()
                          : 'C',
                      style: AppStyles.heading1.copyWith(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_candidate!.name, style: AppStyles.heading2),
                  const SizedBox(height: 4),
                  if (_candidate!.appliedAt != null) ...[
                    Text(
                      'Applied ${_formatDate(_candidate!.appliedAt!)}',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (_candidate!.applicationStatus != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _candidate!.applicationStatus!,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _candidate!.applicationStatus!,
                        style: AppStyles.bodySmall.copyWith(
                          color: _getStatusColor(
                            _candidate!.applicationStatus!,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: AppStyles.heading3),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email_outlined, 'Email', _candidate!.email),
            if (_candidate!.phone != null && _candidate!.phone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_outlined, 'Phone', _candidate!.phone!),
            ],
            if (_candidate!.basicInfo != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.location_on_outlined,
                'Address',
                '${_candidate!.basicInfo!.region}, ${_candidate!.basicInfo!.address}',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.attach_money,
                'Expected Salary',
                '\$${_candidate!.basicInfo!.expectedSalary.toInt()}/month',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(value, style: AppStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreeningAnswers() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz_outlined, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text('Screening Questions', style: AppStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            ..._candidate!.screeningAnswers.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _candidate!.screeningAnswers.length - 1
                      ? 16
                      : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${index + 1}: ${answer.question}',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        answer.answer,
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCVDownload() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text('Resume/CV', style: AppStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _downloadCV,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.primaryGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _candidate!.cvFileName ?? 'Resume.pdf',
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to download',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.download_rounded,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadCV() async {
    if (_candidate?.cvUrl == null) return;

    final baseUrl = 'http://localhost:5000';
    final cvUrl = _candidate!.cvUrl!.startsWith('http')
        ? _candidate!.cvUrl!
        : '$baseUrl${_candidate!.cvUrl}';

    try {
      final uri = Uri.parse(cvUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open CV'),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.success;
      case 'shortlisted':
        return AppColors.primaryGreen;
      case 'reviewed':
        return Colors.blue;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Widget _buildMatchInfo() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Match Score', style: AppStyles.heading3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getMatchColor(
                      _candidate!.matchPercentage,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_candidate!.matchPercentage.toInt()}%',
                    style: AppStyles.heading2.copyWith(
                      color: _getMatchColor(_candidate!.matchPercentage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_candidate!.matchExplanation != null) ...[
              const SizedBox(height: 16),
              Text(
                'Match Explanation',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _candidate!.matchExplanation!,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExtractedSkills() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Extracted Skills', style: AppStyles.heading3),
            const SizedBox(height: 12),
            if (_candidate!.extractedSkills.isEmpty)
              Text(
                'No skills extracted yet',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _candidate!.extractedSkills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildCVPreview() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CV Preview', style: AppStyles.heading3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _candidate!.cvText!,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Approve for Interview (Start Chat) button
        if (widget.jobId != null && _candidate!.applicationStatus != 'Accepted' && _candidate!.applicationStatus != 'Rejected') ...[
          PrimaryButton(
            text: 'Approve for Interview',
            onPressed: () => _startChatWithCandidate(),
            icon: Icons.chat_bubble_outline,
          ),
          const SizedBox(height: 12),
          // Accept/Reject buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateStatus('Accepted'),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accept'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateStatus('Rejected'),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Save button
        PrimaryButton(
          text: _isSaving
              ? 'Processing...'
              : (_isSaved ? 'Saved ✓ (Tap to Remove)' : 'Save Candidate'),
          onPressed: _isSaving ? () {} : () => _toggleSaveCandidate(),
          icon: _isSaving
              ? Icons.hourglass_empty
              : (_isSaved ? Icons.bookmark : Icons.bookmark_outline),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _contactCandidate,
          icon: const Icon(Icons.email_outlined),
          label: const Text('Contact Candidate'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            side: const BorderSide(color: AppColors.primaryGreen, width: 2),
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

  Future<void> _startChatWithCandidate() async {
    if (widget.jobId == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await _apiService.startChat(
        candidateId: widget.candidateId,
        jobId: widget.jobId!,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      if (response['success'] == true && response['data'] != null) {
        final chatData = response['data'];
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatData['id'],
                candidateId: widget.candidateId,
                jobId: widget.jobId,
                otherUserName: _candidate?.name ?? 'Candidate',
                otherUserPhoto: _candidate?.profilePicture,
                jobTitle: widget.jobTitle ?? 'Job Position',
                isHR: true,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to start chat'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (widget.jobId == null) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status == 'Accepted' ? 'Accept' : 'Reject'} Candidate?'),
        content: Text(
          status == 'Accepted'
              ? 'Are you sure you want to accept this candidate for the position?'
              : 'Are you sure you want to reject this application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: status == 'Accepted' ? AppColors.success : AppColors.error,
            ),
            child: Text(status == 'Accepted' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _apiService.updateApplicationStatus(
        candidateId: widget.candidateId,
        jobId: widget.jobId!,
        status: status,
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Candidate ${status.toLowerCase()} successfully!'),
              backgroundColor: status == 'Accepted' ? AppColors.success : AppColors.error,
            ),
          );
          // Reload to update status
          _loadCandidateDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update status'),
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

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.primaryGreen;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
