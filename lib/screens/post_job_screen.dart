import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedExperienceLevel = 'Entry Level';
  bool _isLoading = false;

  final List<String> _experienceLevels = [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Expert',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final response = await _apiService.createJob({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requiredSkills': skillsList,
        'experienceLevel': _selectedExperienceLevel,
      });

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to post job'),
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
                child: LoadingOverlay(
                  isLoading: _isLoading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildJobTitleField(),
                          const SizedBox(height: 20),
                          _buildDescriptionField(),
                          const SizedBox(height: 20),
                          _buildSkillsField(),
                          const SizedBox(height: 20),
                          _buildExperienceLevelDropdown(),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            text: 'Post Job',
                            onPressed: _submitJob,
                            icon: Icons.check_circle_outline,
                          ),
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
          Text('Post New Job', style: AppStyles.heading1),
        ],
      ),
    );
  }

  Widget _buildJobTitleField() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Title',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Senior Flutter Developer',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter job title';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Description',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Describe the job role, responsibilities, and requirements...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter job description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsField() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Skills',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Separate skills with commas',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillsController,
              decoration: InputDecoration(
                hintText: 'e.g. Flutter, Dart, Firebase, REST API',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter required skills';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceLevelDropdown() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experience Level',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedExperienceLevel,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _experienceLevels.map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedExperienceLevel = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
