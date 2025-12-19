import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/skill.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/skill_widgets.dart';

class SkillAnalysisScreen extends StatefulWidget {
  const SkillAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<SkillAnalysisScreen> createState() => _SkillAnalysisScreenState();
}

class _SkillAnalysisScreenState extends State<SkillAnalysisScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  SkillAnalysis? _analysis;
  String? _error;
  String _selectedCategory = 'All'; // All, Technical, Soft

  @override
  void initState() {
    super.initState();
    _loadSkillAnalysis();
  }

  Future<void> _loadSkillAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getSkillsAnalysis();
      setState(() {
        _analysis = SkillAnalysis.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Skill> _getFilteredSkills() {
    if (_analysis == null) return [];

    switch (_selectedCategory) {
      case 'Technical':
        return _analysis!.technicalSkills;
      case 'Soft':
        return _analysis!.softSkills;
      default:
        return [..._analysis!.technicalSkills, ..._analysis!.softSkills];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: LoadingOverlay(
          isLoading: _isLoading && _analysis == null,
          child: SafeArea(
            child: _error != null
                ? _buildError()
                : _analysis == null
                ? const SizedBox()
                : Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadSkillAnalysis,
                          color: AppColors.primaryGreen,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 24),
                                  _buildCategoryFilter(),
                                  const SizedBox(height: 24),
                                  _buildSkillsList(),
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
            Text('Failed to load skill analysis', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadSkillAnalysis,
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
          IconButtonCircular(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white.withOpacity(0.3),
            iconColor: AppColors.textPrimary,
          ),
          const SizedBox(width: 16),
          Text('Skill Analysis', style: AppStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.primaryTeal],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Skills Extracted', style: AppStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '${_analysis!.totalSkills}',
                  style: AppStyles.heading1.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Technical: ${_analysis!.technicalSkills.length}',
                style: AppStyles.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Soft: ${_analysis!.softSkills.length}',
                style: AppStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Row(
      children: [
        _buildFilterChip('All'),
        const SizedBox(width: 12),
        _buildFilterChip('Technical'),
        const SizedBox(width: 12),
        _buildFilterChip('Soft'),
      ],
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryTeal],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.5),
          ),
        ),
        child: Text(
          category,
          style: AppStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    final skills = _getFilteredSkills();

    if (skills.isEmpty) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text('No skills found', style: AppStyles.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: skills.map((skill) => _buildSkillCard(skill)).toList(),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(skill.name, style: AppStyles.heading3)),
              SkillLevelIndicator(level: skill.level),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: skill.category == 'Technical'
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : AppColors.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              skill.category,
              style: AppStyles.bodySmall.copyWith(
                color: skill.category == 'Technical'
                    ? AppColors.primaryGreen
                    : AppColors.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Proficiency', style: AppStyles.bodySmall)),
              Text(
                '${skill.proficiency.toInt()}%',
                style: AppStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProficiencyBar(value: skill.proficiency),
          if (skill.explanation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      skill.explanation!,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
