import 'package:flutter/material.dart';
import 'job_detail_screen.dart';
import '../constants/jobs_data.dart';

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
  @override
  void initState() {
    super.initState();
    // Convert JobsData list to mutable list with IconData
    allJobs = JobsData.allJobs.map((job) {
      final jobCopy = Map<String, dynamic>.from(job);
      jobCopy['logo'] = JobsData.getCompanyLogo(job['company'] as String);
      jobCopy['logoColor'] = JobsData.getCompanyColor(job['company'] as String);
      return jobCopy;
    }).toList();
  }

  late List<Map<String, dynamic>> allJobs;

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
      margin: EdgeInsets.only(bottom: index == allJobs.length - 1 ? 0 : 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
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
                        color: isSaved
                            ? const Color(0xff3F6CDF)
                            : Colors.grey[600],
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
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffECF0FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job['type'] as String,
                      style: const TextStyle(
                        color: Color(0xff3F6CDF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: 0.3,
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
