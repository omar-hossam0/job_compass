import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_candidate.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';

class CandidateListScreen extends StatefulWidget {
  final String jobId;

  const CandidateListScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<HRCandidate> _candidates = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getJobCandidates(widget.jobId);
      
      print('🔍 Candidate List Response: $response');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        print('📦 Data: $data');
        
        // The backend wraps candidates in a data object
        final candidatesData = data['candidates'];
        print('👥 Candidates: $candidatesData');
        
        if (candidatesData is! List) {
          throw Exception('Candidates data is not a list: ${candidatesData.runtimeType}');
        }
        
        setState(() {
          _candidates = (candidatesData as List)
              .map((c) => HRCandidate.fromJson(c))
              .toList();
          // Sort by match percentage descending
          _candidates.sort(
            (a, b) => b.matchPercentage.compareTo(a.matchPercentage),
          );
          _isLoading = false;
        });
        
        print('✅ Loaded ${_candidates.length} candidates');
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load candidates';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading candidates: $e');
      print('📚 Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildError()
                    : _buildCandidatesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Candidates', style: AppStyles.heading1),
                if (_candidates.isNotEmpty)
                  Text(
                    '${_candidates.length} matched',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
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
          Text('Failed to load candidates', style: AppStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCandidates,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList() {
    if (_candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No candidates yet', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Candidates will appear here when they apply',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCandidates,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _candidates.length,
        itemBuilder: (context, index) {
          final candidate = _candidates[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCandidateCard(candidate, index + 1),
          );
        },
      ),
    );
  }

  Widget _buildCandidateCard(HRCandidate candidate, int rank) {
    return GlassCard(
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/hr/candidate-details',
          arguments: candidate.id,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? AppColors.primaryGreen.withOpacity(0.15)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: AppStyles.bodyMedium.copyWith(
                    color: rank <= 3
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile picture
              CircleAvatar(
                radius: 24,
                backgroundImage: candidate.profilePicture != null
                    ? NetworkImage(candidate.profilePicture!)
                    : null,
                backgroundColor: AppColors.primaryGreen,
                child: candidate.profilePicture == null
                    ? Text(
                        candidate.name.isNotEmpty
                            ? candidate.name[0].toUpperCase()
                            : 'C',
                        style: AppStyles.heading3.copyWith(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Candidate info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: AppStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.email,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Match percentage
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getMatchColor(
                        candidate.matchPercentage,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${candidate.matchPercentage.toInt()}%',
                      style: AppStyles.bodyMedium.copyWith(
                        color: _getMatchColor(candidate.matchPercentage),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Match',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.primaryGreen;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
