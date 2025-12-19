class HRDashboardData {
  final String companyName;
  final int activeJobsCount;
  final int totalCandidatesCount;
  final List<Map<String, dynamic>> recentJobs;

  HRDashboardData({
    required this.companyName,
    required this.activeJobsCount,
    required this.totalCandidatesCount,
    required this.recentJobs,
  });

  factory HRDashboardData.fromJson(Map<String, dynamic> json) {
    return HRDashboardData(
      companyName: json['companyName'] ?? 'Company',
      activeJobsCount: json['activeJobsCount'] ?? 0,
      totalCandidatesCount: json['totalCandidatesCount'] ?? 0,
      recentJobs: json['recentJobs'] != null
          ? List<Map<String, dynamic>>.from(json['recentJobs'])
          : [],
    );
  }
}
