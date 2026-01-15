import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_candidate_match.dart';
import '../models/hr_job.dart';
import '../services/api_service.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({Key? key}) : super(key: key);

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<HRJob> _jobs = [];
  String? _error;
  bool _isMatching = false;
  String? _matchingJobId;

  List<HRCandidateMatch> _matches = [];
  String? _matchesJobTitle;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getHRJobs();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _jobs = (response['data'] as List)
              .map((job) => HRJob.fromJson(job))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load jobs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _findMatchesForJob(HRJob job) async {
    setState(() {
      _isMatching = true;
      _matchingJobId = job.id;
    });

    try {
      final response = await _apiService.matchCVsToJob(job.id);

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _matches = (response['data'] as List)
              .map((item) => HRCandidateMatch.fromJson(item))
              .toList();
          _matchesJobTitle = response['jobTitle']?.toString() ?? job.title;
        });

        if (!mounted) return;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildMatchesSheet(),
        );

        if (mounted) {
          setState(() {
            _matches = [];
            _matchesJobTitle = null;
          });
        }
      } else {
        final message = response['message'] ?? 'Failed to load matches';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finding matches: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMatching = false;
          _matchingJobId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildError()
                  : _buildJobsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Posted Jobs',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load jobs', style: AppStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No jobs posted yet', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Post your first job to get started',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildJobCard(job),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(HRJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/hr/job-details',
            arguments: job.id,
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: job.status == 'active'
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF757575),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (job.status == 'active'
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFF757575))
                                    .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        job.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF0D47A1).withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.people_rounded,
                      '${job.applicantsCount} applicants',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.military_tech_rounded,
                      job.experienceLevel,
                    ),
                  ],
                ),
                if (job.requiredSkills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/hr/candidates',
                          arguments: job.id,
                        ),
                        icon: const Icon(Icons.people_alt_rounded),
                        label: const Text('View Applicants'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D47A1),
                          side: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isMatching && _matchingJobId == job.id
                            ? null
                            : () => _findMatchesForJob(job),
                        icon: _isMatching && _matchingJobId == job.id
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.manage_search_rounded),
                        label: Text(
                          _isMatching && _matchingJobId == job.id
                              ? 'Finding...'
                              : 'Find Matches',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F7FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top CV Matches',
                            style: AppStyles.heading2.copyWith(
                              color: const Color(0xFF0D47A1),
                            ),
                          ),
                          if (_matchesJobTitle != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'for "${_matchesJobTitle}"',
                              style: AppStyles.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _matches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_outlined,
                                size: 54,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No matching CVs found yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D26),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ensure candidates have uploaded their CVs and that job descriptions include required skills.',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        itemCount: _matches.length,
                        itemBuilder: (context, index) {
                          return _buildMatchCard(_matches[index], index);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(HRCandidateMatch candidate, int index) {
    final matchColor = candidate.matchScore >= 70
        ? const Color(0xFF2E7D32)
        : candidate.matchScore >= 45
            ? const Color(0xFFF9A825)
            : const Color(0xFFC62828);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    if (candidate.phone != null && candidate.phone!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          candidate.phone!,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${candidate.matchScore.toStringAsFixed(1)}% match',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: matchColor,
                  ),
                ),
              ),
            ],
          ),
          if (candidate.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: candidate.skills.take(6).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D47A1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (candidate.resumePreview != null && candidate.resumePreview!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                candidate.resumePreview!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/hr/candidate-details',
                    arguments: candidate.id,
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D47A1),
                    side: const BorderSide(color: Color(0xFF0D47A1), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/hr/candidate-details',
                  arguments: candidate.id,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Review CV',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
