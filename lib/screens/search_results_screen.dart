import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/glass_card.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';
import '../services/api_service.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final query = args['query'] ?? '';
        if (query.isNotEmpty) {
          _loadSuggestions(query);
        }
      }
    });
  }

  Future<void> _loadSuggestions(String query) async {
    setState(() => _loadingSuggestions = true);
    try {
      final response = await _apiService.getJobSuggestions(query);
      if (response['success'] && mounted) {
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(
            (response['data'] ?? []).map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );
        });
      }
    } catch (e) {
      // Silently fail
    } finally {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Search Results')),
        body: const Center(child: Text('No search data')),
      );
    }

    final String query = args['query'] ?? '';
    final List<dynamic> resultsData = args['results'] ?? [];
    final int count = args['count'] ?? 0;

    final List<Job> jobs = resultsData
        .map((json) => Job.fromJson(json))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.gradientStart,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Results',
              style: AppStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              '$count jobs found for "$query"',
              style: AppStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: jobs.isEmpty
            ? _buildEmptyState(query)
            : Column(
                children: [
                  // Show suggestions at top if available
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Related Jobs',
                                style: AppStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...(_suggestions.take(3).map((suggestion) {
                            return InkWell(
                              onTap: () {
                                if (suggestion['jobId'] != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/job-details',
                                    arguments: suggestion['jobId'],
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      size: 18,
                                      color: AppColors.primaryGreen,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            suggestion['text'] ?? '',
                                            style: AppStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          if (suggestion['company'] != null)
                                            Text(
                                              suggestion['company'],
                                              style: AppStyles.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()),
                        ],
                      ),
                    ),
                  // Job results
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobCard(
                            job: jobs[index],
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/job-details',
                                arguments: jobs[index],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: AppStyles.heading2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'No results for "$query"\nTry different keywords',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
