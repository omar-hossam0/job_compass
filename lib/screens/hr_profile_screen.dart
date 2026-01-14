import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/glass_card.dart';

class HRProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;

  const HRProfileScreen({Key? key, this.initialProfile}) : super(key: key);

  @override
  State<HRProfileScreen> createState() => _HRProfileScreenState();
}

class _HRProfileScreenState extends State<HRProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _companyNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _companySizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  late final List<TextEditingController> _trackedControllers;

  @override
  void initState() {
    super.initState();
    _trackedControllers = [
      _companyNameController,
      _contactNameController,
      _emailController,
      _phoneController,
      _websiteController,
      _industryController,
      _companySizeController,
      _locationController,
      _descriptionController,
    ];
    for (final controller in _trackedControllers) {
      controller.addListener(_onFieldChanged);
    }

    if (widget.initialProfile != null) {
      _applyProfileData(widget.initialProfile!);
      _isLoading = false;
    }
    _loadProfile();
  }

  @override
  void dispose() {
    for (final controller in _trackedControllers) {
      controller.removeListener(_onFieldChanged);
    }
    _companyNameController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _companySizeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getHRProfile();
      if (response['success'] == true && mounted) {
        final data = response['profile'] as Map<String, dynamic>?;
        if (data != null) {
          _applyProfileData(data);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyProfileData(Map<String, dynamic> data) {
    _companyNameController.text = (data['companyName'] ?? '').toString();
    _contactNameController.text = (data['contactName'] ?? '').toString();
    _emailController.text = (data['email'] ?? '').toString();
    _phoneController.text = (data['phone'] ?? data['contactPhone'] ?? '')
        .toString();
    _websiteController.text = (data['website'] ?? data['companyWebsite'] ?? '')
        .toString();
    _industryController.text = (data['industry'] ?? '').toString();
    _companySizeController.text = (data['companySize'] ?? '').toString();
    _locationController.text =
        (data['location'] ?? data['companyLocation'] ?? '').toString();
    _descriptionController.text =
        (data['description'] ?? data['companyDescription'] ?? '').toString();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = <String, dynamic>{
        'companyName': _companyNameController.text.trim(),
        'contactName': _contactNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'website': _websiteController.text.trim(),
        'industry': _industryController.text.trim(),
        'companySize': _companySizeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      payload.removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty),
      );

      final response = await _apiService.updateHRProfile(payload);
      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response['message'] ?? 'Update failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileSummaryCard(),
                          const SizedBox(height: 24),
                          _buildCompanyDetailsSection(),
                          const SizedBox(height: 24),
                          _buildContactDetailsSection(),
                          const SizedBox(height: 24),
                          _buildAboutSection(),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            text: 'Save Changes',
                            onPressed: _saveProfile,
                            isLoading: _isSaving,
                          ),
                        ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.12),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Company Profile',
            style: AppStyles.heading1.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  _companyNameController.text.isNotEmpty
                      ? _companyNameController.text[0].toUpperCase()
                      : 'C',
                  style: AppStyles.heading2.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _companyNameController.text.isEmpty
                        ? 'Company name'
                        : _companyNameController.text,
                    style: AppStyles.heading2,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _industryController.text.isEmpty
                        ? 'Industry not set'
                        : _industryController.text,
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (_companySizeController.text.isNotEmpty)
                        _buildInfoChip(
                          Icons.group_outlined,
                          _companySizeController.text,
                        ),
                      if (_locationController.text.isNotEmpty)
                        _buildInfoChip(
                          Icons.location_on_outlined,
                          _locationController.text,
                        ),
                      if (_websiteController.text.isNotEmpty)
                        _buildInfoChip(Icons.link, _websiteController.text),
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

  Widget _buildCompanyDetailsSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company Details', style: AppStyles.heading3),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _companyNameController,
              label: 'Company Name',
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Company name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _industryController,
              label: 'Industry',
              hintText: 'e.g. Software, Healthcare',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _companySizeController,
              label: 'Company Size',
              hintText: 'e.g. 51-200 employees',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Headquarters',
              hintText: 'City, Country',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              hintText: 'https://company.com',
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetailsSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Details', style: AppStyles.heading3),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _contactNameController,
              label: 'Contact Person',
              hintText: 'Primary HR contact name',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About Company', style: AppStyles.heading3),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Company Overview',
              hintText: 'Share a brief overview about your company',
              maxLines: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
