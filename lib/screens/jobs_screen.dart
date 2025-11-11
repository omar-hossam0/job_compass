import 'package:flutter/material.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  final List<String> savedJobIds;
  final Function(String) onToggleSave;

  const JobsScreen({
    super.key,
    required this.savedJobIds,
    required this.onToggleSave,
  });

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late List<Map<String, dynamic>> allJobs;

  @override
  void initState() {
    super.initState();
    allJobs = _getAllJobs();
  }

  List<Map<String, dynamic>> _getAllJobs() {
    return [
      // Google
      {
        'id': 'google_1',
        'company': 'Google',
        'location': 'Mountain View, California',
        'title': 'Senior Product Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'google_2',
        'company': 'Google',
        'location': 'San Francisco, California',
        'title': 'UX/UI Designer',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'google_3',
        'company': 'Google',
        'location': 'London, UK',
        'title': 'Lead Designer',
        'type': 'Full Time',
        'salary': '\$13K - \$18K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      // Apple
      {
        'id': 'apple_1',
        'company': 'Apple',
        'location': 'Cupertino, California',
        'title': 'Senior UX Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'apple_2',
        'company': 'Apple',
        'location': 'San Francisco, California',
        'title': 'Interaction Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'apple_3',
        'company': 'Apple',
        'location': 'Berlin, Germany',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      // Microsoft
      {
        'id': 'microsoft_1',
        'company': 'Microsoft',
        'location': 'Redmond, Washington',
        'title': 'Senior Designer',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      {
        'id': 'microsoft_2',
        'company': 'Microsoft',
        'location': 'Seattle, Washington',
        'title': 'Design Researcher',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      {
        'id': 'microsoft_3',
        'company': 'Microsoft',
        'location': 'Toronto, Canada',
        'title': 'UI Designer',
        'type': 'Full Time',
        'salary': '\$8K - \$12K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      // Amazon
      {
        'id': 'amazon_1',
        'company': 'Amazon',
        'location': 'Seattle, Washington',
        'title': 'Senior UX Designer',
        'type': 'Full Time',
        'salary': '\$13K - \$17K',
        'logo': Icons.shopping_cart,
        'logoColor': const Color(0xffFF9900),
      },
      {
        'id': 'amazon_2',
        'company': 'Amazon',
        'location': 'Austin, Texas',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.shopping_cart,
        'logoColor': const Color(0xffFF9900),
      },
      // Meta (Facebook)
      {
        'id': 'meta_1',
        'company': 'Meta',
        'location': 'Menlo Park, California',
        'title': 'UI/UX Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      {
        'id': 'meta_2',
        'company': 'Meta',
        'location': 'Dublin, Ireland',
        'title': 'Design Strategist',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      // Netflix
      {
        'id': 'netflix_1',
        'company': 'Netflix',
        'location': 'Los Gatos, California',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.play_arrow,
        'logoColor': const Color(0xffE50914),
      },
      {
        'id': 'netflix_2',
        'company': 'Netflix',
        'location': 'Tokyo, Japan',
        'title': 'UX Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.play_arrow,
        'logoColor': const Color(0xffE50914),
      },
      // Tesla
      {
        'id': 'tesla_1',
        'company': 'Tesla',
        'location': 'Palo Alto, California',
        'title': 'Designer - Automotive UI',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.electric_car,
        'logoColor': const Color(0xffCC0000),
      },
      {
        'id': 'tesla_2',
        'company': 'Tesla',
        'location': 'Austin, Texas',
        'title': 'Product Design Engineer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.electric_car,
        'logoColor': const Color(0xffCC0000),
      },
      // IBM
      {
        'id': 'ibm_1',
        'company': 'IBM',
        'location': 'Armonk, New York',
        'title': 'Senior Design Consultant',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.computer,
        'logoColor': const Color(0xff0F62FE),
      },
      {
        'id': 'ibm_2',
        'company': 'IBM',
        'location': 'Austin, Texas',
        'title': 'UX/UI Specialist',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.computer,
        'logoColor': const Color(0xff0F62FE),
      },
      // LinkedIn
      {
        'id': 'linkedin_1',
        'company': 'LinkedIn',
        'location': 'Sunnyvale, California',
        'title': 'Senior Product Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.business,
        'logoColor': const Color(0xff0A66C2),
      },
      {
        'id': 'linkedin_2',
        'company': 'LinkedIn',
        'location': 'San Francisco, California',
        'title': 'Design Manager',
        'type': 'Full Time',
        'salary': '\$13K - \$17K',
        'logo': Icons.business,
        'logoColor': const Color(0xff0A66C2),
      },
      // Adobe
      {
        'id': 'adobe_1',
        'company': 'Adobe',
        'location': 'San Jose, California',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.brush,
        'logoColor': const Color(0xffDA1F26),
      },
      {
        'id': 'adobe_2',
        'company': 'Adobe',
        'location': 'Edinburgh, Scotland',
        'title': 'UX Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.brush,
        'logoColor': const Color(0xffDA1F26),
      },
      // Spotify
      {
        'id': 'spotify_1',
        'company': 'Spotify',
        'location': 'Stockholm, Sweden',
        'title': 'Design Lead',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.music_note,
        'logoColor': const Color(0xff1DB954),
      },
      {
        'id': 'spotify_2',
        'company': 'Spotify',
        'location': 'New York, USA',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.music_note,
        'logoColor': const Color(0xff1DB954),
      },
      // Uber
      {
        'id': 'uber_1',
        'company': 'Uber',
        'location': 'San Francisco, California',
        'title': 'Senior UX Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.directions_car,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'uber_2',
        'company': 'Uber',
        'location': 'Berlin, Germany',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.directions_car,
        'logoColor': const Color(0xff000000),
      },
      // Airbnb
      {
        'id': 'airbnb_1',
        'company': 'Airbnb',
        'location': 'San Francisco, California',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.home,
        'logoColor': const Color(0xffFF5A5F),
      },
      {
        'id': 'airbnb_2',
        'company': 'Airbnb',
        'location': 'Paris, France',
        'title': 'Design Researcher',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.home,
        'logoColor': const Color(0xffFF5A5F),
      },
      // Slack
      {
        'id': 'slack_1',
        'company': 'Slack',
        'location': 'San Francisco, California',
        'title': 'Senior Product Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.chat,
        'logoColor': const Color(0xffE01E5A),
      },
      {
        'id': 'slack_2',
        'company': 'Slack',
        'location': 'Toronto, Canada',
        'title': 'UX Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.chat,
        'logoColor': const Color(0xffE01E5A),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F5),
        elevation: 0,
        title: const Text(
          'All Jobs',
          style: TextStyle(
            color: Color(0xff070C19),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xff070C19),
              size: 20,
            ),
          ),
        ),
        centerTitle: false,
        leadingWidth: 40,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          children: [
            ...List.generate(
              allJobs.length,
              (index) => _buildJobCard(allJobs[index], index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    final bool isSaved = widget.savedJobIds.contains(job['id']);

    return Container(
      margin: EdgeInsets.only(
        bottom: index == allJobs.length - 1 ? 0 : 16,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with company and save button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            job['logo'] as IconData,
                            color: job['logoColor'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['company'] as String,
                                style: const TextStyle(
                                  color: Color(0xff070C19),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                job['location'] as String,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onToggleSave(job['id'] as String);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSaved
                            ? const Color(0xff3F6CDF).withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color:
                            isSaved ? const Color(0xff3F6CDF) : Colors.grey[600],
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Job title
              Text(
                job['title'] as String,
                style: const TextStyle(
                  color: Color(0xff070C19),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Job type and salary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffECF0FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job['type'] as String,
                      style: const TextStyle(
                        color: Color(0xff3F6CDF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    job['salary'] as String,
                    style: const TextStyle(
                      color: Color(0xff070C19),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
