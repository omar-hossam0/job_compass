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
  final List<String> customQuestions; // Custom questions from HR

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
    this.customQuestions = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      // Handle salary - can be object {min, max, currency} or number
      double salaryValue = 0.0;
      if (json['salary'] != null) {
        if (json['salary'] is Map) {
          // If salary is an object, use min value or max or 0
          final salaryMap = json['salary'] as Map;
          final minVal = salaryMap['min'];
          final maxVal = salaryMap['max'];
          if (minVal is num) {
            salaryValue = minVal.toDouble();
          } else if (maxVal is num) {
            salaryValue = maxVal.toDouble();
          } else {
            salaryValue = 0.0;
          }
        } else if (json['salary'] is num) {
          salaryValue = (json['salary'] as num).toDouble();
        }
      }

      // Handle employmentType - backend uses jobType instead
      List<String> employmentTypes = [];
      if (json['employmentType'] != null && json['employmentType'] is List) {
        employmentTypes = List<String>.from(json['employmentType']);
      } else if (json['jobType'] != null) {
        employmentTypes = [json['jobType'].toString()];
      }
      if (employmentTypes.isEmpty) {
        employmentTypes = ['Full-time'];
      }

      // Handle postedAt - backend uses createdAt
      DateTime postedDate = DateTime.now();
      try {
        if (json['postedAt'] != null) {
          postedDate = DateTime.parse(json['postedAt'].toString());
        } else if (json['createdAt'] != null) {
          postedDate = DateTime.parse(json['createdAt'].toString());
        }
      } catch (e) {
        postedDate = DateTime.now();
      }

      // Handle matchScore safely
      double matchScoreValue = 0.0;
      if (json['matchScore'] != null) {
        if (json['matchScore'] is num) {
          matchScoreValue = (json['matchScore'] as num).toDouble();
        } else if (json['matchScore'] is String) {
          matchScoreValue = double.tryParse(json['matchScore']) ?? 0.0;
        }
      }

      // Handle applicantsCount
      int applicantsCountValue = 0;
      if (json['applicants'] != null && json['applicants'] is List) {
        applicantsCountValue = (json['applicants'] as List).length;
      } else if (json['applicantsCount'] != null) {
        applicantsCountValue = (json['applicantsCount'] is num)
            ? (json['applicantsCount'] as num).toInt()
            : 0;
      }

      return Job(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        company: (json['company'] ?? 'Company').toString(),
        companyLogo: json['companyLogo']?.toString(),
        description: (json['description'] ?? '').toString(),
        location: (json['location'] ?? 'Remote').toString(),
        employmentType: employmentTypes,
        salary: salaryValue,
        salaryPeriod: (json['salaryPeriod'] ?? '/year').toString(),
        experienceYears: () {
          // Try experienceYears first, then parse experienceLevel
          if (json['experienceYears'] != null &&
              json['experienceYears'] is num) {
            return (json['experienceYears'] as num).toInt();
          }
          // Parse experienceLevel string to estimate years
          final expLevel = (json['experienceLevel'] ?? '')
              .toString()
              .toLowerCase();
          if (expLevel.contains('entry')) return 0;
          if (expLevel.contains('mid')) return 3;
          if (expLevel.contains('senior')) return 5;
          if (expLevel.contains('executive')) return 10;
          return 0;
        }(),
        requiredSkills: json['requiredSkills'] != null
            ? List<String>.from(json['requiredSkills'])
            : [],
        matchScore: matchScoreValue,
        missingSkillsCount: (json['missingSkillsCount'] ?? 0) is num
            ? (json['missingSkillsCount'] as num).toInt()
            : 0,
        postedAt: postedDate,
        applicantsCount: applicantsCountValue,
        customQuestions: json['customQuestions'] != null
            ? List<String>.from(json['customQuestions'])
            : [],
      );
    } catch (e) {
      // Fallback with default values if parsing fails
      print('Error parsing job: $e');
      print('Job data: $json');
      return Job(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        title: (json['title'] ?? 'Unknown Job').toString(),
        company: (json['company'] ?? 'Company').toString(),
        companyLogo: null,
        description: (json['description'] ?? '').toString(),
        location: 'Remote',
        employmentType: ['Full-time'],
        salary: 0.0,
        salaryPeriod: '/year',
        experienceYears: 0,
        requiredSkills: [],
        matchScore: 0.0,
        missingSkillsCount: 0,
        postedAt: DateTime.now(),
        applicantsCount: 0,
        customQuestions: [],
      );
    }
  }
}
