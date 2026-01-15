class HRCandidateMatch {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final double matchScore;
  final List<String> skills;
  final String? resumePreview;

  HRCandidateMatch({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.matchScore,
    required this.skills,
    this.resumePreview,
  });

  factory HRCandidateMatch.fromJson(Map<String, dynamic> json) {
    return HRCandidateMatch(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown Candidate').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      matchScore: () {
        final raw = json['matchScore'] ?? json['similarity_score'];
        if (raw is num) return raw.toDouble();
        if (raw is String) return double.tryParse(raw) ?? 0;
        return 0.0;
      }(),
      skills: () {
        if (json['skills'] is List) {
          return List<String>.from(
            (json['skills'] as List)
                .where((skill) => skill != null)
                .map((skill) => skill.toString()),
          );
        }
        if (json['extractedSkills'] is List) {
          return List<String>.from(
            (json['extractedSkills'] as List)
                .where((skill) => skill != null)
                .map((skill) => skill.toString()),
          );
        }
        return <String>[];
      }(),
      resumePreview: json['resumeText']?.toString(),
    );
  }
}
