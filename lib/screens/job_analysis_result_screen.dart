import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

/// Model for missing skill with learning link
class MissingSkillItem {
  final String skill;
  final double confidence;
  final String priority;
  final String youtubeLink;

  MissingSkillItem({
    required this.skill,
    required this.confidence,
    required this.priority,
    required this.youtubeLink,
  });

  factory MissingSkillItem.fromJson(Map<String, dynamic> json) {
    return MissingSkillItem(
      skill: json['skill'] ?? '',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      priority: json['priority'] ?? 'MEDIUM',
      youtubeLink:
          json['youtube'] ??
          'https://www.youtube.com/results?search_query=${Uri.encodeComponent((json['skill'] ?? '') + ' tutorial')}',
    );
  }
}

/// Model for job analysis result
class JobAnalysisResult {
  final String jobTitle;
  final String company;
  final double matchScore;
  final List<String> matchedSkills;
  final List<MissingSkillItem> missingSkills;
  final int totalJobSkills;
  final int totalCvSkills;

  JobAnalysisResult({
    required this.jobTitle,
    required this.company,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.totalJobSkills,
    required this.totalCvSkills,
  });

  factory JobAnalysisResult.fromJson(Map<String, dynamic> json) {
    List<MissingSkillItem> parseMissingSkills(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return MissingSkillItem.fromJson(item);
          } else if (item is String) {
            return MissingSkillItem(
              skill: item,
              confidence: 0.5,
              priority: 'MEDIUM',
              youtubeLink:
                  'https://www.youtube.com/results?search_query=${Uri.encodeComponent('$item tutorial')}',
            );
          }
          return MissingSkillItem(
            skill: item.toString(),
            confidence: 0.5,
            priority: 'MEDIUM',
            youtubeLink:
                'https://www.youtube.com/results?search_query=${Uri.encodeComponent('${item.toString()} tutorial')}',
          );
        }).toList();
      }
      return [];
    }

    List<String> parseMatchedSkills(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    }

    return JobAnalysisResult(
      jobTitle: json['jobTitle'] ?? '',
      company: json['company'] ?? '',
      matchScore: (json['matchScore'] ?? json['matchPercentage'] ?? 0)
          .toDouble(),
      matchedSkills: parseMatchedSkills(json['matchedSkills']),
      missingSkills: parseMissingSkills(json['missingSkills']),
      totalJobSkills: json['totalJobSkills'] ?? 0,
      totalCvSkills: json['totalCvSkills'] ?? 0,
    );
  }
}

class JobAnalysisResultScreen extends StatefulWidget {
  final String jobId;
  final String? jobTitle;

  const JobAnalysisResultScreen({Key? key, required this.jobId, this.jobTitle})
    : super(key: key);

  @override
  State<JobAnalysisResultScreen> createState() =>
      _JobAnalysisResultScreenState();
}

class _JobAnalysisResultScreenState extends State<JobAnalysisResultScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  JobAnalysisResult? _result;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.analyzeJobForUser(widget.jobId);
      print('🔍 Analysis Response: $response');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _result = JobAnalysisResult.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to analyze job';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading analysis: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
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
        child: LoadingOverlay(
          isLoading: _isLoading,
          child: SafeArea(
            child: _error != null
                ? _buildError()
                : _result == null
                ? const SizedBox()
                : Column(
                    children: [
                      _buildAppBar(),
                      _buildMatchScoreHeader(),
                      _buildTabBar(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildMatchedSkillsTab(),
                            _buildMissingSkillsTab(),
                          ],
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
            Text('Failed to analyze job', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadAnalysis,
              icon: Icons.refresh,
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CV Analysis', style: AppStyles.heading2),
                if (_result != null)
                  Text(
                    _result!.jobTitle,
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

  Widget _buildMatchScoreHeader() {
    final matchColor = _getMatchColor(_result!.matchScore);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [const Color(0xFFDDF8E8), const Color(0xFFC8F1EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 94,
                    height: 94,
                    child: CircularProgressIndicator(
                      value: _result!.matchScore / 100,
                      strokeWidth: 9,
                      backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(matchColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_result!.matchScore.toStringAsFixed(0)}%',
                        style: AppStyles.heading1.copyWith(
                          color: matchColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Match',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _result!.jobTitle,
                    style: AppStyles.heading3.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _result!.company,
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildStatChip(
                        Icons.check_circle,
                        '${_result!.matchedSkills.length} Matched',
                        AppColors.success,
                      ),
                      _buildStatChip(
                        Icons.warning_amber,
                        '${_result!.missingSkills.length} Missing',
                        AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.primaryTeal],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Matched'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _result!.matchedSkills.length.toString(),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Missing'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _result!.missingSkills.length.toString(),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchedSkillsTab() {
    if (_result!.matchedSkills.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No matched skills',
        subtitle: 'Your CV doesn\'t have any matching skills for this job',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _result!.matchedSkills.length,
      itemBuilder: (context, index) {
        final skill = _result!.matchedSkills[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    skill,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'In CV',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissingSkillsTab() {
    if (_result!.missingSkills.isEmpty) {
      return _buildEmptyState(
        icon: Icons.celebration,
        title: 'No missing skills!',
        subtitle: 'Your CV covers all the required skills for this job',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _result!.missingSkills.length,
      itemBuilder: (context, index) {
        final skill = _result!.missingSkills[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.skill,
                            style: AppStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildPriorityBadge(skill.priority),
                              const SizedBox(width: 8),
                              Text(
                                'Confidence: ${(skill.confidence * 100).toStringAsFixed(0)}%',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Learning Link Button
                InkWell(
                  onTap: () => _launchUrl(skill.youtubeLink),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.red.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.red,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Learn ${skill.skill}',
                                style: AppStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              Text(
                                'Watch tutorials on YouTube',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red.shade400,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toUpperCase()) {
      case 'HIGH':
        color = AppColors.error;
        break;
      case 'MEDIUM':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: AppStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count, {Color? color}) {
    final badgeColor = color ?? AppColors.primaryTeal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: AppStyles.bodySmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(title, style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
