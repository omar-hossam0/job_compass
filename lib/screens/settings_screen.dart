import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account', style: AppStyles.heading3),
                        const SizedBox(height: 16),
                        _buildAccountSection(),
                        const SizedBox(height: 24),
                        Text('Preferences', style: AppStyles.heading3),
                        const SizedBox(height: 16),
                        _buildPreferencesSection(),
                        const SizedBox(height: 24),
                        Text('Security', style: AppStyles.heading3),
                        const SizedBox(height: 16),
                        _buildSecuritySection(),
                        const SizedBox(height: 24),
                        Text('About', style: AppStyles.heading3),
                        const SizedBox(height: 16),
                        _buildAboutSection(),
                        const SizedBox(height: 32),
                        _buildLogoutButton(),
                      ],
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
          Text('Settings', style: AppStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return GlassCard(
      child: Column(
        children: [
          _buildSettingItem(
            Icons.person_outline,
            'Edit Profile',
            'Update your personal information',
            () => Navigator.pushNamed(context, '/profile'),
          ),
          const Divider(height: 24),
          FutureBuilder<Map<String, dynamic>>(
            future: _apiService.get('/auth/me'),
            builder: (context, snapshot) {
              final email = snapshot.data?['user']?['email'] ?? 'Loading...';
              return _buildSettingItem(
                Icons.email_outlined,
                'Email',
                email,
                null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return GlassCard(
      child: Column(
        children: [
          _buildLanguageItem(),
          const Divider(height: 24),
          _buildSwitchItem(
            Icons.notifications_outlined,
            'Push Notifications',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          const Divider(height: 24),
          _buildSwitchItem(
            Icons.email_outlined,
            'Email Notifications',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return GlassCard(
      child: Column(
        children: [
          _buildSettingItem(
            Icons.lock_outline,
            'Change Password',
            'Update your password',
            () => _showChangePasswordDialog(),
          ),
          const Divider(height: 24),
          _buildSettingItem(
            Icons.security,
            'Privacy Settings',
            'Manage your data and privacy',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Column(
        children: [
          _buildSettingItem(
            Icons.info_outline,
            'About Job Compass',
            'Version 1.0.0',
            null,
          ),
          const Divider(height: 24),
          _buildSettingItem(
            Icons.description_outlined,
            'Terms of Service',
            'Read our terms',
            null,
          ),
          const Divider(height: 24),
          _buildSettingItem(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'Read our policy',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppStyles.bodySmall),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
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
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildLanguageItem() {
    return InkWell(
      onTap: () => _showLanguageDialog(),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_selectedLanguage, style: AppStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Logout',
          onPressed: () => _showLogoutDialog(),
          icon: Icons.logout,
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _showDeleteAccountDialog(),
          child: Text(
            'Delete Account',
            style: AppStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language', style: AppStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('العربية'),
            _buildLanguageOption('Français'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      activeColor: AppColors.primaryGreen,
      onChanged: (value) {
        setState(() => _selectedLanguage = value!);
        Navigator.pop(context);
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password', style: AppStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Change',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: AppStyles.heading3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _apiService.clearToken();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: AppStyles.heading3),
        content: Text(
          'This action is permanent. All your data will be deleted.',
          style: AppStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // Implement account deletion logic
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
