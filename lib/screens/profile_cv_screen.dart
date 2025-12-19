import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/skill_widgets.dart';

class ProfileCVScreen extends StatefulWidget {
  const ProfileCVScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCVScreen> createState() => _ProfileCVScreenState();
}

class _ProfileCVScreenState extends State<ProfileCVScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isUploading = false;
  Student? _student;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getStudentProfile();
      setState(() {
        _student = Student.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);

        File file = File(result.files.single.path!);
        await _apiService.uploadCV(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CV uploaded successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadProfile();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: LoadingOverlay(
          isLoading: _isLoading && _student == null,
          child: SafeArea(
            child: _error != null
                ? _buildError()
                : _student == null
                    ? const SizedBox()
                    : Column(
                        children: [
                          _buildAppBar(),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _loadProfile,
                              color: AppColors.primaryGreen,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildProfileHeader(),
                                      const SizedBox(height: 24),
                                      _buildPersonalInfo(),
                                      const SizedBox(height: 24),
                                      _buildCVSection(),
                                      const SizedBox(height: 24),
                                      _buildExtractedSkills(),
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
            Text('Failed to load profile', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(_error ?? 'Unknown error', style: AppStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadProfile,
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
          Text('Profile & CV', style: AppStyles.heading2),
          const Spacer(),
          IconButtonCircular(
            icon: Icons.settings_outlined,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            backgroundColor: Colors.white.withOpacity(0.3),
            iconColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundImage: _student!.profilePicture != null
                  ? NetworkImage(_student!.profilePicture!)
                  : null,
              backgroundColor: AppColors.primaryGreen,
              child: _student!.profilePicture == null
                  ? Text(
                      _student!.name.isNotEmpty ? _student!.name[0].toUpperCase() : 'U',
                      style: AppStyles.heading1.copyWith(color: Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(_student!.name, style: AppStyles.heading2),
          const SizedBox(height: 4),
          Text(_student!.email, style: AppStyles.bodyMedium),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completion',
                      style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_student!.profileCompletion}%',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _student!.profileCompletion / 100,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Information', style: AppStyles.heading3),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              _buildInfoRow(Icons.person_outline, 'Full Name', _student!.name),
              const Divider(height: 24),
              _buildInfoRow(Icons.email_outlined, 'Email', _student!.email),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCVSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CV Management', style: AppStyles.heading3),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              if (_student!.cvUrl != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_circle, color: AppColors.success, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CV Uploaded',
                            style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _student!.cvUploadedAt != null
                                ? 'Uploaded on ${_formatDate(_student!.cvUploadedAt!)}'
                                : 'Recently uploaded',
                            style: AppStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                text: _student!.cvUrl != null ? 'Update CV' : 'Upload CV',
                onPressed: _pickAndUploadCV,
                isLoading: _isUploading,
                icon: _student!.cvUrl != null ? Icons.refresh : Icons.upload_file,
                width: double.infinity,
              ),
              if (_student!.cvUrl == null) ...[
                const SizedBox(height: 12),
                Text(
                  'Upload your CV to get personalized job matches',
                  style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExtractedSkills() {
    if (_student!.skills.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Extracted Skills', style: AppStyles.heading3),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/skills-analysis'),
              child: Text(
                'View All',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _student!.skills.take(10).map((skill) => SkillChip(label: skill)).toList(),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
