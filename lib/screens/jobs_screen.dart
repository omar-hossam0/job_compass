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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
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
              size: 18,
            ),
          ),
        ),
        centerTitle: false,
        leadingWidth: 40,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
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
      margin: EdgeInsets.only(bottom: index == allJobs.length - 1 ? 0 : 14),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
          );
        },
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image header with bookmark
              Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      (job['logoColor'] as Color).withOpacity(0.8),
                      (job['logoColor'] as Color).withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(painter: _PatternPainter()),
                      ),
                    ),
                    // Company logo in center
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          job['logo'] as IconData,
                          color: job['logoColor'] as Color,
                          size: 28,
                        ),
                      ),
                    ),
                    // Bookmark button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          widget.onToggleSave(job['id'] as String);
                          setState(() {});
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved
                                ? const Color(0xff3F6CDF)
                                : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job title and company
                      Text(
                        job['title'] as String,
                        style: const TextStyle(
                          color: Color(0xff070C19),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        job['company'] as String,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        job['description'] as String? ??
                            'Join our team and make an impact',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Footer with salary, views, and learn more
                      Row(
                        children: [
                          // Salary
                          Icon(
                            Icons.attach_money,
                            size: 15,
                            color: Colors.grey[500],
                          ),
                          Text(
                            job['salary'] as String,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Views count (random for demo)
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 15,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${(index + 1) * 47}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          // Learn more button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JobDetailScreen(job: job),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'learn more',
                                  style: TextStyle(
                                    color: const Color(0xff3F6CDF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xff3F6CDF),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
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
}

// Pattern painter for background decoration
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some geometric patterns
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 3; j++) {
        final x = i * 60.0;
        final y = j * 40.0;
        canvas.drawLine(Offset(x, y), Offset(x + 30, y + 20), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
