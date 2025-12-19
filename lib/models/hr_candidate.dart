class HRCandidate {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? cvText;
  final List<String> extractedSkills;
  final double matchPercentage;
  final String? matchExplanation;
  final String? profilePicture;
  final DateTime? appliedAt;

  HRCandidate({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cvText,
    required this.extractedSkills,
    required this.matchPercentage,
    this.matchExplanation,
    this.profilePicture,
    this.appliedAt,
  });

  factory HRCandidate.fromJson(Map<String, dynamic> json) {
    return HRCandidate(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      cvText: json['cvText'],
      extractedSkills: json['extractedSkills'] != null
          ? List<String>.from(json['extractedSkills'])
          : [],
      matchPercentage: (json['matchPercentage'] ?? 0).toDouble(),
      matchExplanation: json['matchExplanation'],
      profilePicture: json['profilePicture'],
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'])
          : null,
    );
  }
}
