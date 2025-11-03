import 'package:flutter/material.dart';

class JobMatchingScreen extends StatelessWidget {
  const JobMatchingScreen({super.key});

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
                      'وظائف مناسبة ليك',
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
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildJobCard(
                      context,
                      title: 'Frontend Developer',
                      company: 'Tech Solutions Inc.',
                      matchScore: 85,
                      skills: ['React', 'JavaScript', 'Git', 'CSS'],
                      salary: '\$60k - \$80k',
                      location: 'Remote',
                    ),
                    const SizedBox(height: 16),
                    _buildJobCard(
                      context,
                      title: 'Full Stack Developer',
                      company: 'Digital Innovations',
                      matchScore: 78,
                      skills: ['Python', 'Django', 'React', 'PostgreSQL'],
                      salary: '\$70k - \$95k',
                      location: 'Cairo, Egypt',
                    ),
                    const SizedBox(height: 16),
                    _buildJobCard(
                      context,
                      title: 'UI/UX Designer',
                      company: 'Creative Studio',
                      matchScore: 72,
                      skills: [
                        'Figma',
                        'Adobe XD',
                        'Prototyping',
                        'User Research',
                      ],
                      salary: '\$50k - \$70k',
                      location: 'Hybrid',
                    ),
                    const SizedBox(height: 16),
                    _buildJobCard(
                      context,
                      title: 'Data Analyst',
                      company: 'Analytics Corp',
                      matchScore: 68,
                      skills: ['Python', 'SQL', 'Excel', 'Power BI'],
                      salary: '\$55k - \$75k',
                      location: 'Remote',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String title,
    required String company,
    required int matchScore,
    required List<String> skills,
    required String salary,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: matchScore >= 80
                        ? [const Color(0xff10b981), const Color(0xff34d399)]
                        : matchScore >= 70
                        ? [const Color(0xff3b82f6), const Color(0xff60a5fa)]
                        : [const Color(0xfff59e0b), const Color(0xfffbbf24)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$matchScore%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.attach_money_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
              Text(
                salary,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'المهارات المطلوبة:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff3b82f6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xff60a5fa).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: Color(0xff60a5fa),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to skill gap
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3b82f6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'عرض الفجوة المهارية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
