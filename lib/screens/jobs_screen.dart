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
      {
        'id': 'youtube_1',
        'company': 'Youtube',
        'location': 'San Bruno, California, USA',
        'title': 'Senior UX Researcher',
        'type': 'Full Time',
        'salary': '\$8K - \$10K',
        'logo': Icons.play_circle_filled,
        'logoColor': const Color(0xffFF0000),
      },
      {
        'id': 'apple_1',
        'company': 'Apple',
        'location': 'Cupertino, California',
        'title': 'Junior Product Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$15K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'facebook_1',
        'company': 'Facebook',
        'location': 'Menlo Park, California',
        'title': 'UI/UX Designer',
        'type': 'Full Time',
        'salary': '\$8K - \$12K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      {
        'id': 'google_1',
        'company': 'Google',
        'location': 'Mountain View, California',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$7K - \$11K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
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
        'id': 'apple_2',
        'company': 'Apple',
        'location': 'Cupertino, California',
        'title': 'Senior UX Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'google_2',
        'company': 'Google',
        'location': 'Mountain View, California',
        'title': 'UX/UI Designer',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'microsoft_2',
        'company': 'Microsoft',
        'location': 'Redmond, Washington',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      {
        'id': 'facebook_2',
        'company': 'Facebook',
        'location': 'Menlo Park, California',
        'title': 'Senior Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      {
        'id': 'youtube_2',
        'company': 'Youtube',
        'location': 'San Bruno, California, USA',
        'title': 'Product Manager - Design',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.play_circle_filled,
        'logoColor': const Color(0xffFF0000),
      },
      {
        'id': 'google_3',
        'company': 'Google',
        'location': 'Mountain View, California',
        'title': 'Lead Designer',
        'type': 'Full Time',
        'salary': '\$13K - \$18K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'apple_3',
        'company': 'Apple',
        'location': 'San Francisco, California',
        'title': 'Interaction Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'microsoft_3',
        'company': 'Microsoft',
        'location': 'Seattle, Washington',
        'title': 'Design Researcher',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      {
        'id': 'facebook_3',
        'company': 'Facebook',
        'location': 'Menlo Park, California',
        'title': 'Motion Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      {
        'id': 'youtube_3',
        'company': 'Youtube',
        'location': 'San Bruno, California, USA',
        'title': 'Visual Designer',
        'type': 'Full Time',
        'salary': '\$7K - \$11K',
        'logo': Icons.play_circle_filled,
        'logoColor': const Color(0xffFF0000),
      },
      {
        'id': 'google_4',
        'company': 'Google',
        'location': 'London, UK',
        'title': 'Senior Product Designer',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'apple_4',
        'company': 'Apple',
        'location': 'Berlin, Germany',
        'title': 'User Experience Designer',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'microsoft_4',
        'company': 'Microsoft',
        'location': 'Toronto, Canada',
        'title': 'UI Designer',
        'type': 'Full Time',
        'salary': '\$8K - \$12K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      {
        'id': 'facebook_4',
        'company': 'Facebook',
        'location': 'Dublin, Ireland',
        'title': 'Product Designer',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
      },
      {
        'id': 'youtube_4',
        'company': 'Youtube',
        'location': 'Tokyo, Japan',
        'title': 'Designer - Content',
        'type': 'Full Time',
        'salary': '\$8K - \$12K',
        'logo': Icons.play_circle_filled,
        'logoColor': const Color(0xffFF0000),
      },
      {
        'id': 'google_5',
        'company': 'Google',
        'location': 'Singapore',
        'title': 'Interaction Designer',
        'type': 'Full Time',
        'salary': '\$9K - \$13K',
        'logo': Icons.g_mobiledata,
        'logoColor': const Color(0xff4285F4),
      },
      {
        'id': 'apple_5',
        'company': 'Apple',
        'location': 'Sydney, Australia',
        'title': 'Design Systems Specialist',
        'type': 'Full Time',
        'salary': '\$10K - \$14K',
        'logo': Icons.apple,
        'logoColor': const Color(0xff000000),
      },
      {
        'id': 'microsoft_5',
        'company': 'Microsoft',
        'location': 'Amsterdam, Netherlands',
        'title': 'Principal Designer',
        'type': 'Full Time',
        'salary': '\$12K - \$16K',
        'logo': Icons.window,
        'logoColor': const Color(0xff00A4EF),
      },
      {
        'id': 'facebook_5',
        'company': 'Facebook',
        'location': 'Paris, France',
        'title': 'Design Strategist',
        'type': 'Full Time',
        'salary': '\$11K - \$15K',
        'logo': Icons.facebook,
        'logoColor': const Color(0xff1877F2),
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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    job['salary'] as String,
                    style: const TextStyle(
                      color: Color(0xff070C19),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
