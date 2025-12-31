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
          if (minVal != null && minVal is num) {
            salaryValue = minVal.toDouble();
          } else if (maxVal != null && maxVal is num) {
            salaryValue = maxVal.toDouble();
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyLogo': companyLogo,
      'description': description,
      'location': location,
      'employmentType': employmentType,
      'salary': salary,
      'salaryPeriod': salaryPeriod,
      'experienceYears': experienceYears,
      'requiredSkills': requiredSkills,
      'matchScore': matchScore,
      'missingSkillsCount': missingSkillsCount,
      'postedAt': postedAt.toIso8601String(),
      'applicantsCount': applicantsCount,
      'customQuestions': customQuestions,
    };
  }

  // Helper method to format salary
  String get formattedSalary {
    if (salary <= 0) return 'Negotiable';
    if (salary >= 1000) {
      return '\$${(salary / 1000).toStringAsFixed(0)}k$salaryPeriod';
    }
    return '\$${salary.toStringAsFixed(0)}$salaryPeriod';
  }

  // Helper method to get match percentage color
  String get matchLevel {
    if (matchScore >= 80) return 'Excellent';
    if (matchScore >= 60) return 'Good';
    if (matchScore >= 40) return 'Fair';
    return 'Low';
  }

  // Helper method to check if recently posted
  bool get isRecent {
    final difference = DateTime.now().difference(postedAt);
    return difference.inDays <= 7;
  }

  // Helper method to format posted date
  String get formattedPostedDate {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()}w ago';
    return '${(difference.inDays / 30).floor()}mo ago';
  }
}
