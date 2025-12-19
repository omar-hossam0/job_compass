import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/skill.dart';
import '../widgets/glass_card.dart';
import '../widgets/common_widgets.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class SkillGapScreen extends StatefulWidget {
  final String jobId;

  const SkillGapScreen({super.key, required this.jobId});

  @override
  State<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends State<SkillGapScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  SkillGap? _skillGap;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSkillGap();
  }

  Future<void> _loadSkillGap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getSkillGap(widget.jobId);

      if (response['success'] && mounted) {
        setState(() {
          _skillGap = SkillGap.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load skill gap';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
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
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : _error != null
                    ? _buildErrorState()
                    : _buildContent(),
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
          ),
          const Text('Skill Gap Analysis', style: AppStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          Text(_error ?? 'Error', style: AppStyles.bodyLarge),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadSkillGap, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_skillGap == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadSkillGap,
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall match
            _buildOverallMatch(),
            const SizedBox(height: 24),

            // Skill comparisons
            _buildSkillComparisons(),
            const SizedBox(height: 24),

            // Missing skills
            if (_skillGap!.missingSkills.isNotEmpty) ...[
              _buildMissingSkills(),
              const SizedBox(height: 24),
            ],

            // Improvement suggestions
            if (_skillGap!.improvementSuggestions.isNotEmpty)
              _buildImprovementSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallMatch() {
    final matchPercentage = _skillGap!.overallMatch;

    return GlassCard(
      child: Column(
        children: [
          const Text('Overall Match', style: AppStyles.heading3),
          const SizedBox(height: 20),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: matchPercentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      matchPercentage >= 70
                          ? AppColors.success
                          : matchPercentage >= 50
                          ? AppColors.warning
                          : AppColors.error,
                    ),
                  ),
                ),
                Text(
                  '${matchPercentage.toInt()}%',
                  style: AppStyles.heading1.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillComparisons() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skill Comparison', style: AppStyles.heading3),
          const SizedBox(height: 16),
          ...List.generate(_skillGap!.skillComparisons.length, (index) {
            final comparison = _skillGap!.skillComparisons[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comparison.skillName, style: AppStyles.bodyLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Required', style: AppStyles.bodySmall),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: comparison.requiredLevel / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Level',
                              style: AppStyles.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: comparison.currentLevel / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMissingSkills() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Missing Skills', style: AppStyles.heading3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillGap!.missingSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  skill,
                  style: AppStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Improvement Suggestions', style: AppStyles.heading3),
          const SizedBox(height: 12),
          ...List.generate(_skillGap!.improvementSuggestions.length, (index) {
            final suggestion = _skillGap!.improvementSuggestions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accentGold,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(suggestion, style: AppStyles.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
