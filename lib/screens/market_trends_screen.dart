import 'package:flutter/material.dart';

class MarketTrendsScreen extends StatelessWidget {
  const MarketTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'تريندات السوق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Skills Card
                      _buildSectionTitle('أكثر 10 مهارات طلباً'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSkillBar(
                              'Python',
                              95,
                              const Color(0xff3b82f6),
                            ),
                            _buildSkillBar(
                              'JavaScript',
                              90,
                              const Color(0xfff59e0b),
                            ),
                            _buildSkillBar(
                              'React',
                              85,
                              const Color(0xff06b6d4),
                            ),
                            _buildSkillBar('SQL', 82, const Color(0xff10b981)),
                            _buildSkillBar(
                              'TypeScript',
                              78,
                              const Color(0xff8b5cf6),
                            ),
                            _buildSkillBar(
                              'Node.js',
                              75,
                              const Color(0xffec4899),
                            ),
                            _buildSkillBar(
                              'Docker',
                              70,
                              const Color(0xff6366f1),
                            ),
                            _buildSkillBar('AWS', 68, const Color(0xfff43f5e)),
                            _buildSkillBar('Git', 92, const Color(0xff14b8a6)),
                            _buildSkillBar(
                              'MongoDB',
                              65,
                              const Color(0xffa855f7),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Most Demanded Jobs
                      _buildSectionTitle('الوظائف الأكثر طلباً'),
                      const SizedBox(height: 16),
                      _buildJobDemandCard(
                        'Full Stack Developer',
                        '2,500+ فرصة',
                        const Color(0xff3b82f6),
                      ),
                      const SizedBox(height: 12),
                      _buildJobDemandCard(
                        'Frontend Developer',
                        '1,800+ فرصة',
                        const Color(0xff10b981),
                      ),
                      const SizedBox(height: 12),
                      _buildJobDemandCard(
                        'Backend Developer',
                        '1,500+ فرصة',
                        const Color(0xff8b5cf6),
                      ),
                      const SizedBox(height: 12),
                      _buildJobDemandCard(
                        'DevOps Engineer',
                        '1,200+ فرصة',
                        const Color(0xfff59e0b),
                      ),
                      const SizedBox(height: 12),
                      _buildJobDemandCard(
                        'Data Scientist',
                        '1,000+ فرصة',
                        const Color(0xffec4899),
                      ),

                      const SizedBox(height: 32),

                      // Salary Ranges
                      _buildSectionTitle('نطاق الرواتب (سنوياً)'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSalaryRow(
                              'Junior Developer',
                              '\$40k - \$60k',
                            ),
                            const SizedBox(height: 16),
                            _buildSalaryRow(
                              'Mid-Level Developer',
                              '\$60k - \$90k',
                            ),
                            const SizedBox(height: 16),
                            _buildSalaryRow(
                              'Senior Developer',
                              '\$90k - \$130k',
                            ),
                            const SizedBox(height: 16),
                            _buildSalaryRow('Tech Lead', '\$120k - \$160k'),
                            const SizedBox(height: 16),
                            _buildSalaryRow(
                              'Engineering Manager',
                              '\$150k - \$200k+',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Growth Trends
                      _buildSectionTitle('اتجاهات النمو'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff10b981), Color(0xff34d399)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff10b981).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildTrendItem(
                              '🚀',
                              'AI & Machine Learning',
                              '+45% نمو',
                            ),
                            const Divider(color: Colors.white24, height: 32),
                            _buildTrendItem(
                              '☁️',
                              'Cloud Computing',
                              '+38% نمو',
                            ),
                            const Divider(color: Colors.white24, height: 32),
                            _buildTrendItem(
                              '📱',
                              'Mobile Development',
                              '+32% نمو',
                            ),
                            const Divider(color: Colors.white24, height: 32),
                            _buildTrendItem('🔐', 'Cybersecurity', '+40% نمو'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSkillBar(String skill, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDemandCard(
    String jobTitle,
    String opportunities,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                jobTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            opportunities,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(String role, String range) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          role,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          range,
          style: TextStyle(
            color: const Color(0xff60a5fa),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(String emoji, String title, String growth) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          growth,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
