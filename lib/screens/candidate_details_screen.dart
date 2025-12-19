import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_candidate.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

class CandidateDetailsScreen extends StatefulWidget {
  final String candidateId;

  const CandidateDetailsScreen({Key? key, required this.candidateId})
    : super(key: key);

  @override
  State<CandidateDetailsScreen> createState() => _CandidateDetailsScreenState();
}

class _CandidateDetailsScreenState extends State<CandidateDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  HRCandidate? _candidate;
  String? _error;
  bool _isSaved = false;

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

  Future<void> _saveCandidate() async {
    try {
      final response = await _apiService.saveCandidate(widget.candidateId);
      if (mounted) {
        if (response['success'] == true) {
          setState(() => _isSaved = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidate saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to save candidate'),
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
          _buildMatchInfo(),
          const SizedBox(height: 20),
          _buildExtractedSkills(),
          if (_candidate!.cvText != null) ...[
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
                  Text(
                    _candidate!.email,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_candidate!.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _candidate!.phone!,
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
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
        PrimaryButton(
          text: _isSaved ? 'Saved ✓' : 'Save Candidate',
          onPressed: () {
            if (!_isSaved) _saveCandidate();
          },
          icon: _isSaved ? Icons.bookmark : Icons.bookmark_outline,
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

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.primaryGreen;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
