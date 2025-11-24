import 'package:flutter/material.dart';
import 'job_application_screen.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff070C19), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Application Details',
          style: TextStyle(
            color: Color(0xff070C19),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xff070C19)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with company logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Company Logo
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.job['logo'] as IconData,
                    color: widget.job['logoColor'] as Color,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),

                // Job Title
                Text(
                  widget.job['title'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff070C19),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Company Name and Location
                Text(
                  'at',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.job['company']}, ${jobData['companyInfo']['location']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Location and Salary
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      jobData['companyInfo']['location'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    Text(
                      widget.job['salary'] as String,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDetailBadge(widget.job['type'] as String),
                    const SizedBox(width: 8),
                    _buildDetailBadge('Senior'),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xff3F6CDF),
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: const Color(0xff3F6CDF),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Job Description'),
                Tab(text: 'Reviews'),
                Tab(text: 'About Us'),
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
              ],
            ),
          ),

          // Apply Now Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationScreen(job: widget.job),
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
                  'Apply Now!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff3F6CDF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff3F6CDF),
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
          // Job Description Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff070C19),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'See More',
                      style: TextStyle(
                        color: const Color(0xff3F6CDF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xff3F6CDF),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'So, in this company is you will work as a Product Designer, at Tokopedia, Indonesia which is one of the Unicorns Indonesia.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What you will do in this company is you will do some work like UI UX Designer. This is application can making sure that the application we enjoy. The application...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Requirements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Requirements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff070C19),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'See More',
                      style: TextStyle(
                        color: const Color(0xff3F6CDF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xff3F6CDF),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            '3 - 4 years experienced as Product Designer',
            'Basic Graphic Design Skills',
            'Research and Analysis Skills',
            'Making Prototype | Invision or Zeplin |',
          ].map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xff070C19),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        req,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
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
              fontSize: 16,
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
                      color: const Color(0xff3F6CDF).withOpacity(0.1),
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
