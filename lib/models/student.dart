import 'job.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final int profileCompletion;
  final double skillMatchScore;
  final String? cvUrl;
  final String? cvFileName;
  final DateTime? cvUploadedAt;
  final List<String> skills;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.profileCompletion,
    required this.skillMatchScore,
    this.cvUrl,
    this.cvFileName,
    this.cvUploadedAt,
    this.skills = const [],
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      profileCompletion: json['profileCompletion'] ?? 0,
      skillMatchScore: (json['skillMatchScore'] ?? 0).toDouble(),
      cvUrl: json['cvUrl'],
      cvFileName: json['cvFileName'],
      cvUploadedAt: json['cvUploadedAt'] != null
          ? DateTime.parse(json['cvUploadedAt'])
          : null,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'profileCompletion': profileCompletion,
      'skillMatchScore': skillMatchScore,
      'cvUrl': cvUrl,
      'cvFileName': cvFileName,
      'cvUploadedAt': cvUploadedAt?.toIso8601String(),
      'skills': skills,
    };
  }
}

class DashboardData {
  final Student student;
  final List<Job> topMatchedJobs;
  final int totalJobMatches;
  final int skillsCount;

  DashboardData({
    required this.student,
    required this.topMatchedJobs,
    required this.totalJobMatches,
    required this.skillsCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      student: Student.fromJson(json['student'] ?? {}),
      topMatchedJobs: json['topMatchedJobs'] != null
          ? (json['topMatchedJobs'] as List)
                .map((j) => Job.fromJson(j))
                .toList()
          : [],
      totalJobMatches: json['totalJobMatches'] ?? 0,
      skillsCount: json['skillsCount'] ?? 0,
    );
  }
}
