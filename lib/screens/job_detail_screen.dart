import 'package:flutter/material.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get job-specific data based on company
  Map<String, dynamic> _getJobData() {
    final company = widget.job['company'] as String;

    final Map<String, Map<String, dynamic>> jobDataMap = {
      'Google': {
        'description': [
          'Deliver a well-crafted design that follows standard for consistency, quality and user experience.',
          'Design creative solutions that deliver not only value customer but also solve business objectives.',
          'You are also required to contribute to the design and critics, conceptual discussion, and also maintaining consistency of design system.',
        ],
        'skills': ['Lead', 'Ux Design', 'Problem Solving', 'Critical Thinking'],
        'companyInfo': {
          'name': 'Google LLC',
          'location': 'California, USA',
          'type': 'Technology Company',
          'employees': '150,000+',
          'founded': '1998',
          'website': 'www.google.com',
          'description':
              'Google is a multinational technology company that specializes in Internet-related services and products.',
        },
        'requirements': [
          '5+ years of experience in product design',
          'Strong portfolio demonstrating UX/UI design skills',
          'Proficiency in Figma, Sketch, or Adobe XD',
          'Experience with design systems',
        ],
        'salaryRange': '\$5,000 - \$7,000',
        'benefits': [
          'Health Insurance',
          'Dental Coverage',
          '401(k) Matching',
          'Unlimited PTO',
          'Remote Work',
          'Learning Budget',
        ],
      },
      'Apple': {
        'description': [
          'Create innovative and intuitive user experiences for millions of Apple users worldwide.',
          'Work with cutting-edge technology to design products that define the future.',
          'Collaborate with world-class teams to maintain Apple\'s reputation for excellence in design.',
        ],
        'skills': ['Senior Level', 'UI/UX Design', 'iOS Design', 'Prototyping'],
        'companyInfo': {
          'name': 'Apple Inc.',
          'location': 'Cupertino, California',
          'type': 'Technology & Electronics',
          'employees': '160,000+',
          'founded': '1976',
          'website': 'www.apple.com',
          'description':
              'Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.',
        },
        'requirements': [
          '6+ years of senior-level UX design experience',
          'Deep understanding of Apple design principles',
          'Expert knowledge of design tools',
          'Portfolio showcasing mobile applications',
        ],
        'salaryRange': '\$6,000 - \$8,500',
        'benefits': [
          'Comprehensive Health',
          'Stock Purchase Plan',
          'Generous PTO',
          'Product Discounts',
          'Wellness Programs',
          'Professional Development',
        ],
      },
      'Microsoft': {
        'description': [
          'Design intuitive interfaces that empower users to achieve more.',
          'Contribute to Microsoft\'s mission of empowering every person and organization.',
          'Work on products used by billions of people worldwide.',
        ],
        'skills': ['Mid-level', 'UI Design', 'User Research', 'Collaboration'],
        'companyInfo': {
          'name': 'Microsoft Corporation',
          'location': 'Redmond, Washington',
          'type': 'Technology & Software',
          'employees': '220,000+',
          'founded': '1975',
          'website': 'www.microsoft.com',
          'description':
              'Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide.',
        },
        'requirements': [
          '3-5 years of UI/UX design experience',
          'Experience with enterprise software design',
          'Proficiency in modern design tools',
          'Understanding of accessibility standards',
        ],
        'salaryRange': '\$4,500 - \$6,000',
        'benefits': [
          'Medical & Dental',
          'Retirement Plan',
          'Paid Time Off',
          'Hybrid Work',
          'Tuition Assistance',
          'Technology Stipend',
        ],
      },
      'Pinterest, Inc.': {
        'description': [
          'Design engaging visual experiences that inspire millions of users.',
          'Create motion graphics and animations that bring Pinterest to life.',
          'Collaborate with cross-functional teams to deliver exceptional user experiences.',
        ],
        'skills': ['Senior', 'Motion Design', 'Animation', 'Visual Design'],
        'companyInfo': {
          'name': 'Pinterest, Inc.',
          'location': 'San Francisco, California',
          'type': 'Social Media & Technology',
          'employees': '3,000+',
          'founded': '2010',
          'website': 'www.pinterest.com',
          'description':
              'Pinterest is a visual discovery engine for finding ideas like recipes, home and style inspiration, and more.',
        },
        'requirements': [
          '5+ years of motion design experience',
          'Expert in After Effects and animation tools',
          'Strong portfolio of motion graphics work',
          'Experience with UI/UX animation',
        ],
        'salaryRange': '\$7,000 - \$9,000',
        'benefits': [
          'Full Health Coverage',
          'Equity Compensation',
          'Flexible Schedule',
          'Unlimited Vacation',
          'Learning Budget',
          'Home Office Stipend',
        ],
      },
      'Facebook': {
        'description': [
          'Design innovative user interfaces for billions of Facebook users.',
          'Shape the future of social connection through thoughtful design.',
          'Work on challenging problems at massive scale.',
        ],
        'skills': ['Senior', 'UI Design', 'Design Systems', 'Prototyping'],
        'companyInfo': {
          'name': 'Facebook (Meta)',
          'location': 'Menlo Park, California',
          'type': 'Social Media & Technology',
          'employees': '86,000+',
          'founded': '2004',
          'website': 'www.facebook.com',
          'description':
              'Facebook (Meta) builds technologies that help people connect, find communities, and grow businesses.',
        },
        'requirements': [
          '5+ years of UI design experience',
          'Strong portfolio of mobile and web designs',
          'Experience with design systems',
          'Data-driven design approach',
        ],
        'salaryRange': '\$8,000 - \$10,000',
        'benefits': [
          'Comprehensive Healthcare',
          'RSU Equity',
          'Generous PTO',
          'Remote Work Options',
          'Professional Development',
          'Free Meals',
        ],
      },
    };

    return jobDataMap[company] ??
        {
          'description': ['Join our team and make an impact.'],
          'skills': ['Design', 'Communication'],
          'companyInfo': {
            'name': company,
            'location': widget.job['location'] as String? ?? 'Location',
            'type': 'Technology',
            'employees': '1,000+',
            'founded': '2020',
            'website': 'www.company.com',
            'description': 'A great company to work for.',
          },
          'requirements': ['Relevant experience required'],
          'salaryRange': widget.job['salary'] as String? ?? '\$5K',
          'benefits': ['Health Insurance', 'Paid Time Off'],
        };
  }

  @override
  Widget build(BuildContext context) {
    final jobData = _getJobData();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with company logo
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Company Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      widget.job['logo'] as IconData,
                      color: widget.job['logoColor'] as Color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Title
                  Text(
                    widget.job['title'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff070C19),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Text(
                    jobData['companyInfo']['location'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xff3F6CDF),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xff3F6CDF),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Description'),
                  Tab(text: 'Company'),
                  Tab(text: 'Applicant'),
                  Tab(text: 'Salary'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDescriptionTab(jobData),
                  _buildCompanyTab(jobData),
                  _buildApplicantTab(jobData),
                  _buildSalaryTab(jobData),
                ],
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Application submitted for ${widget.job['title']}!',
                            ),
                            backgroundColor: const Color(0xff3F6CDF),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3F6CDF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffECF0FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening chat with ${widget.job['company']}...',
                            ),
                            backgroundColor: const Color(0xff3F6CDF),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xff3F6CDF),
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(Map<String, dynamic> jobData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Responsibilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            (jobData['description'] as List).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xff3F6CDF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jobData['description'][index],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Skills Needed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (jobData['skills'] as List).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffECF0FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Color(0xff3F6CDF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(Map<String, dynamic> jobData) {
    final companyInfo = jobData['companyInfo'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            companyInfo['name'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            companyInfo['location'],
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          _buildInfoRow('Type', companyInfo['type']),
          _buildInfoRow('Employees', companyInfo['employees']),
          _buildInfoRow('Founded', companyInfo['founded']),
          _buildInfoRow('Website', companyInfo['website']),

          const SizedBox(height: 24),
          const Text(
            'About Company',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            companyInfo['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantTab(Map<String, dynamic> jobData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requirements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            (jobData['requirements'] as List).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xffECF0FC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xff3F6CDF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jobData['requirements'][index],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTab(Map<String, dynamic> jobData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salary Range',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xffECF0FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  jobData['salaryRange'],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3F6CDF),
                  ),
                ),
                const Text(
                  'Monthly',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Benefits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff070C19),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            (jobData['benefits'] as List).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xffECF0FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Color(0xff3F6CDF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jobData['benefits'][index],
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff070C19),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
