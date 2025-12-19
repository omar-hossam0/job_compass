import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';

class HRSettingsScreen extends StatefulWidget {
  const HRSettingsScreen({Key? key}) : super(key: key);

  @override
  State<HRSettingsScreen> createState() => _HRSettingsScreenState();
}

class _HRSettingsScreenState extends State<HRSettingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getHRProfile();
      if (response['success'] == true) {
        setState(() {
          _profile = response['profile'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Clear token
    await _apiService.clearToken();

    // Clear any other stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      // Navigate to auth screen
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSettings(),
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
          Text('Settings', style: AppStyles.heading1),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_profile != null) _buildProfileCard(),
          const SizedBox(height: 20),
          _buildSettingsList(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryGreen,
              child: Text(
                (_profile!['companyName'] ?? 'C')[0].toUpperCase(),
                style: AppStyles.heading1.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile!['companyName'] ?? 'Company Name',
                    style: AppStyles.heading2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile!['email'] ?? '',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Navigate to edit profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile coming soon')),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {
            Navigator.pushNamed(context, '/hr/notifications');
          },
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change password coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & support coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('About coming soon')));
          },
        ),
        const SizedBox(height: 24),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: AppStyles.bodyMedium)),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GlassCard(
      child: InkWell(
        onTap: _logout,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppColors.error),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
