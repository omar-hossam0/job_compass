class HRJob {
  final String id;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String experienceLevel;
  final String status;
  final int applicantsCount;
  final String companyId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HRJob({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.experienceLevel,
    required this.status,
    required this.applicantsCount,
    required this.companyId,
    required this.createdAt,
    this.updatedAt,
  });

  factory HRJob.fromJson(Map<String, dynamic> json) {
    return HRJob(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requiredSkills: json['requiredSkills'] != null
          ? List<String>.from(json['requiredSkills'])
          : [],
      experienceLevel: json['experienceLevel'] ?? '',
      status: json['status'] ?? 'active',
      applicantsCount: json['applicantsCount'] ?? 0,
      companyId: json['company'] ?? json['companyId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requiredSkills': requiredSkills,
      'experienceLevel': experienceLevel,
      'status': status,
    };
  }
}
