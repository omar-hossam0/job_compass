class Student {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final int profileCompletion;
  final double skillMatchScore;
  final String? cvUrl;
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

class Job {
  final String id;
  final String title;
  final String company;
  final String? companyLogo;
  final String description;
  final String location;
  final List<String> employmentType; // Remote, Freelance, Full-time
  final double salary;
  final String salaryPeriod; // /year, /month
  final int experienceYears;
  final List<String> requiredSkills;
  final double matchScore;
  final int missingSkillsCount;
  final DateTime postedAt;
  final int applicantsCount;

  Job({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    required this.description,
    required this.location,
    required this.employmentType,
    required this.salary,
    required this.salaryPeriod,
    required this.experienceYears,
    required this.requiredSkills,
    required this.matchScore,
    required this.missingSkillsCount,
    required this.postedAt,
    required this.applicantsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['companyLogo'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      employmentType: json['employmentType'] != null
          ? List<String>.from(json['employmentType'])
          : [],
      salary: (json['salary'] ?? 0).toDouble(),
      salaryPeriod: json['salaryPeriod'] ?? '/year',
      experienceYears: json['experienceYears'] ?? 0,
      requiredSkills: json['requiredSkills'] != null
          ? List<String>.from(json['requiredSkills'])
          : [],
      matchScore: (json['matchScore'] ?? 0).toDouble(),
      missingSkillsCount: json['missingSkillsCount'] ?? 0,
      postedAt: json['postedAt'] != null
          ? DateTime.parse(json['postedAt'])
          : DateTime.now(),
      applicantsCount: json['applicantsCount'] ?? 0,
    );
  }
}
