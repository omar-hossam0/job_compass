import 'package:flutter/material.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04; // 4% of screen width
    final logoSize = screenWidth * 0.2; // 20% of screen width
    final titleFontSize = screenWidth * 0.06; // 6% of screen width
    final subtitleFontSize = screenWidth * 0.035; // 3.5% of screen width

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff0f172a), Color(0xff1e293b)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(padding.clamp(12.0, 20.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Company Logo
              Container(
                padding: EdgeInsets.all(logoSize.clamp(16.0, 24.0) * 0.8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.job['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.white,
                  size: logoSize.clamp(36.0, 48.0),
                ),
              ),

              const SizedBox(height: 20),

              // Job Title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding.clamp(12.0, 20.0),
                ),
                child: Text(
                  widget.job['role'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize.clamp(20.0, 28.0),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // Company Description
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding.clamp(20.0, 44.0) * 2,
                ),
                child: Text(
                  'The IAPWE or International Association of Professional Writers & Editors came into...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: subtitleFontSize.clamp(11.0, 14.0),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff0f172a),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Share Job',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() => _isFavorite = !_isFavorite);
                        },
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tabs
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xff1e293b),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TabBar(
                          isScrollable: true,
                          indicatorColor: const Color(0xff3b82f6),
                          labelColor: const Color(0xff3b82f6),
                          unselectedLabelColor: Colors.white60,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Jobs'),
                            Tab(text: 'Benefits'),
                            Tab(text: 'Tech stack'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildOverviewTab(),
                              _buildJobsTab(),
                              _buildBenefitsTab(),
                              _buildTechStackTab(),
                            ],
                          ),
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
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Skills & Experience',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('2+ years of non-internship professional data'),
          _buildBulletPoint('You must be adept at analyzing requirements and'),
          _buildBulletPoint('Having prior experience minimum of 2 years on'),
          const SizedBox(height: 24),
          const Text(
            'About the company',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompanyInfo(Icons.business, 'Industry', 'Tech Agency'),
              _buildCompanyInfo(
                Icons.location_on,
                'Headquarters',
                'Main, Italy',
              ),
              _buildCompanyInfo(Icons.people, 'Size', 'More than 50'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Similar remote jobs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Add similar jobs here if needed
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildJobsTab() {
    // Get job-specific responsibilities based on the role
    final role = widget.job['role'] as String;
    List<String> responsibilities;

    if (role.contains('Digital Marketer')) {
      responsibilities = [
        'Develop and execute digital marketing campaigns across multiple channels',
        'Manage social media platforms and create engaging content',
        'Analyze campaign performance and optimize for better ROI',
        'Collaborate with design team to create marketing materials',
        'Monitor SEO/SEM strategies and implement improvements',
        'Generate monthly reports on marketing metrics and KPIs',
      ];
    } else if (role.contains('Product Designer')) {
      responsibilities = [
        'Design user-centered interfaces for web and mobile applications',
        'Create wireframes, prototypes, and high-fidelity mockups',
        'Conduct user research and usability testing',
        'Collaborate with developers to ensure design implementation',
        'Maintain and evolve design system and component libraries',
        'Present design solutions to stakeholders and clients',
      ];
    } else if (role.contains('Frontend Developer')) {
      responsibilities = [
        'Build responsive and performant web applications',
        'Write clean, maintainable code using modern JavaScript frameworks',
        'Implement pixel-perfect designs from mockups',
        'Optimize applications for maximum speed and scalability',
        'Collaborate with backend developers to integrate APIs',
        'Participate in code reviews and maintain documentation',
      ];
    } else {
      responsibilities = [
        'Execute project tasks and deliverables on time',
        'Collaborate with cross-functional teams',
        'Participate in team meetings and planning sessions',
        'Maintain high quality standards in all work',
        'Continuously learn and adopt new technologies',
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Responsibilities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...responsibilities.map((resp) => _buildBulletPoint(resp)).toList(),
          const SizedBox(height: 24),
          const Text(
            'Work Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            Icons.schedule,
            'Working Hours',
            '${widget.job['time']} per week',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.calendar_today,
            'Work Type',
            widget.job['type'] as String,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.location_on,
            'Location',
            widget.job['location'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsTab() {
    // Get job-specific benefits based on the role and location
    final role = widget.job['role'] as String;
    List<Map<String, dynamic>> benefits;

    if (role.contains('Digital Marketer')) {
      benefits = [
        {
          'icon': Icons.attach_money,
          'title': 'Competitive Salary',
          'desc': '\$85-95/hr with performance bonuses',
        },
        {
          'icon': Icons.health_and_safety,
          'title': 'Health Insurance',
          'desc': 'Comprehensive medical and dental coverage',
        },
        {
          'icon': Icons.home_work,
          'title': 'Remote Work',
          'desc': 'Work from anywhere with flexible hours',
        },
        {
          'icon': Icons.school,
          'title': 'Learning Budget',
          'desc': '\$2000/year for courses and conferences',
        },
        {
          'icon': Icons.flight,
          'title': 'Paid Time Off',
          'desc': '25 days annual leave plus public holidays',
        },
        {
          'icon': Icons.devices,
          'title': 'Equipment Provided',
          'desc': 'Latest MacBook Pro and accessories',
        },
      ];
    } else if (role.contains('Product Designer')) {
      benefits = [
        {
          'icon': Icons.attach_money,
          'title': 'Competitive Salary',
          'desc': '\$85-95/hr with equity options',
        },
        {
          'icon': Icons.palette,
          'title': 'Design Tools',
          'desc': 'Figma, Sketch, Adobe CC licenses included',
        },
        {
          'icon': Icons.home_work,
          'title': 'Flexible Location',
          'desc': 'Remote or hybrid work options',
        },
        {
          'icon': Icons.people,
          'title': 'Team Events',
          'desc': 'Quarterly team building and retreats',
        },
        {
          'icon': Icons.school,
          'title': 'Professional Growth',
          'desc': 'Mentorship and career development program',
        },
        {
          'icon': Icons.favorite,
          'title': 'Wellness Program',
          'desc': 'Gym membership and mental health support',
        },
      ];
    } else if (role.contains('Frontend Developer')) {
      benefits = [
        {
          'icon': Icons.attach_money,
          'title': 'Competitive Pay',
          'desc': '\$70-85/hr with regular raises',
        },
        {
          'icon': Icons.code,
          'title': 'Latest Tech Stack',
          'desc': 'Work with cutting-edge technologies',
        },
        {
          'icon': Icons.home_work,
          'title': 'Remote First',
          'desc': '100% remote work opportunity',
        },
        {
          'icon': Icons.school,
          'title': 'Learning Resources',
          'desc': 'Unlimited access to online courses',
        },
        {
          'icon': Icons.coffee,
          'title': 'Work-Life Balance',
          'desc': 'Flexible hours and no overtime pressure',
        },
        {
          'icon': Icons.card_giftcard,
          'title': 'Performance Bonus',
          'desc': 'Quarterly bonuses based on achievements',
        },
      ];
    } else {
      benefits = [
        {
          'icon': Icons.attach_money,
          'title': 'Competitive Salary',
          'desc': 'Market-rate compensation',
        },
        {
          'icon': Icons.health_and_safety,
          'title': 'Health Benefits',
          'desc': 'Medical and insurance coverage',
        },
        {
          'icon': Icons.home_work,
          'title': 'Flexible Work',
          'desc': 'Remote and flexible options',
        },
        {
          'icon': Icons.school,
          'title': 'Professional Development',
          'desc': 'Training and growth opportunities',
        },
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What We Offer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...benefits
              .map(
                (benefit) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xff3b82f6).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          benefit['icon'] as IconData,
                          color: const Color(0xff3b82f6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              benefit['desc'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTechStackTab() {
    // Get job-specific tech stack based on the role
    final role = widget.job['role'] as String;
    List<Map<String, dynamic>> techStack;

    if (role.contains('Digital Marketer')) {
      techStack = [
        {
          'name': 'Google Analytics',
          'category': 'Analytics',
          'icon': Icons.analytics,
        },
        {
          'name': 'Facebook Ads',
          'category': 'Advertising',
          'icon': Icons.ads_click,
        },
        {
          'name': 'Mailchimp',
          'category': 'Email Marketing',
          'icon': Icons.email,
        },
        {'name': 'Hootsuite', 'category': 'Social Media', 'icon': Icons.share},
        {'name': 'Canva', 'category': 'Design', 'icon': Icons.design_services},
        {'name': 'SEMrush', 'category': 'SEO', 'icon': Icons.search},
        {
          'name': 'HubSpot',
          'category': 'Marketing Automation',
          'icon': Icons.hub,
        },
        {'name': 'Google Ads', 'category': 'PPC', 'icon': Icons.campaign},
      ];
    } else if (role.contains('Product Designer')) {
      techStack = [
        {'name': 'Figma', 'category': 'Design Tool', 'icon': Icons.brush},
        {'name': 'Sketch', 'category': 'Design Tool', 'icon': Icons.draw},
        {'name': 'Adobe XD', 'category': 'Prototyping', 'icon': Icons.apps},
        {
          'name': 'InVision',
          'category': 'Collaboration',
          'icon': Icons.group_work,
        },
        {'name': 'Principle', 'category': 'Animation', 'icon': Icons.animation},
        {
          'name': 'Miro',
          'category': 'Whiteboarding',
          'icon': Icons.dashboard_customize,
        },
        {'name': 'Zeplin', 'category': 'Handoff', 'icon': Icons.handshake},
        {'name': 'Framer', 'category': 'Prototyping', 'icon': Icons.devices},
      ];
    } else if (role.contains('Frontend Developer')) {
      techStack = [
        {'name': 'React', 'category': 'Framework', 'icon': Icons.code},
        {'name': 'TypeScript', 'category': 'Language', 'icon': Icons.code_off},
        {'name': 'Next.js', 'category': 'Framework', 'icon': Icons.web},
        {'name': 'Tailwind CSS', 'category': 'Styling', 'icon': Icons.style},
        {
          'name': 'Redux',
          'category': 'State Management',
          'icon': Icons.storage,
        },
        {'name': 'Git', 'category': 'Version Control', 'icon': Icons.source},
        {
          'name': 'Webpack',
          'category': 'Build Tool',
          'icon': Icons.construction,
        },
        {'name': 'Jest', 'category': 'Testing', 'icon': Icons.bug_report},
      ];
    } else {
      techStack = [
        {'name': 'Slack', 'category': 'Communication', 'icon': Icons.chat},
        {'name': 'Jira', 'category': 'Project Management', 'icon': Icons.task},
        {
          'name': 'Zoom',
          'category': 'Video Conferencing',
          'icon': Icons.videocam,
        },
        {
          'name': 'Google Workspace',
          'category': 'Productivity',
          'icon': Icons.work,
        },
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technologies We Use',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: techStack
                .map(
                  (tech) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xff3b82f6).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tech['icon'] as IconData,
                          color: const Color(0xff3b82f6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tech['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              tech['category'] as String,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Technical Requirements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('Proficiency in the above tools and technologies'),
          _buildBulletPoint('Strong portfolio demonstrating relevant work'),
          _buildBulletPoint('Ability to learn and adapt to new technologies'),
          _buildBulletPoint('Experience with agile development methodologies'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff3b82f6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xff3b82f6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
