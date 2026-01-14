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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      requiredSkills: () {
        if (json['requiredSkills'] != null) {
          try {
            if (json['requiredSkills'] is List) {
              return List<String>.from(
                (json['requiredSkills'] as List)
                    .where((s) => s != null)
                    .map((s) => s.toString()),
              );
            }
          } catch (e) {
            print('Error parsing requiredSkills: $e');
          }
        }
        return <String>[];
      }(),
      experienceLevel: (json['experienceLevel'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      applicantsCount: () {
        // Check applicants array first
        if (json['applicants'] != null && json['applicants'] is List) {
          return (json['applicants'] as List).length;
        }
        // Check applicantsCount field
        if (json['applicantsCount'] != null) {
          if (json['applicantsCount'] is num) {
            return (json['applicantsCount'] as num).toInt();
          } else if (json['applicantsCount'] is String) {
            return int.tryParse(json['applicantsCount']) ?? 0;
          }
        }
        return 0;
      }(),
      companyId: (json['company'] ?? json['companyId'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
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
