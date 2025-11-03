import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.06; // 6% of screen width
    final avatarSize = screenWidth * 0.3; // 30% of screen width
    final nameFontSize = screenWidth * 0.07; // 7% of screen width
    final emailFontSize = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff0f172a), Color(0xff1e293b), Color(0xff1e40af)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding.clamp(20.0, 28.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: avatarSize.clamp(100.0, 140.0),
                        height: avatarSize.clamp(100.0, 140.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xff3b82f6), Color(0xff60a5fa)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff3b82f6).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: (avatarSize * 0.5).clamp(50.0, 70.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Omar Hossam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: nameFontSize.clamp(24.0, 32.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'omarhossam@gmail.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: emailFontSize.clamp(14.0, 18.0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Uploaded CV Card
                _buildSectionTitle('Resume'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xfff43f5e).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Color(0xfff43f5e),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Omar_CV.pdf',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded on October 15, 2024',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.download_rounded,
                          color: Color(0xff60a5fa),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Current Skills
                _buildSectionTitle('My Current Skills'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSkillChip('Python', const Color(0xff3b82f6)),
                      _buildSkillChip('SQL', const Color(0xff10b981)),
                      _buildSkillChip('Excel', const Color(0xfff59e0b)),
                      _buildSkillChip('Communication', const Color(0xff8b5cf6)),
                      _buildSkillChip('Leadership', const Color(0xff06b6d4)),
                      _buildSkillChip(
                        'Problem Solving',
                        const Color(0xffec4899),
                      ),
                      _buildSkillChip('Git', const Color(0xff6366f1)),
                      _buildSkillChip('Agile', const Color(0xfff43f5e)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '85%',
                        'Match Rate',
                        const Color(0xff10b981),
                        Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '12',
                        'Suitable Jobs',
                        const Color(0xff3b82f6),
                        Icons.work_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButton(
                  title: 'Edit Profile',
                  icon: Icons.edit_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xff3b82f6), Color(0xff60a5fa)],
                  ),
                  onTap: () {
                    // Edit profile
                  },
                ),

                const SizedBox(height: 16),

                _buildActionButton(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xff8b5cf6), Color(0xffa78bfa)],
                  ),
                  onTap: () {
                    // Settings
                  },
                ),

                const SizedBox(height: 16),

                _buildActionButton(
                  title: 'Logout',
                  icon: Icons.logout_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xfff43f5e), Color(0xfffb7185)],
                  ),
                  onTap: () {
                    // Logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xff1e293b),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Perform logout
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xfff43f5e),
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // App Version
                Center(
                  child: Text(
                    'JobCompass v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
