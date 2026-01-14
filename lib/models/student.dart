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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePicture:
          json['profilePicture']?.toString() ??
          json['profileImage']?.toString(),
      profileCompletion: () {
        if (json['profileCompletion'] != null) {
          if (json['profileCompletion'] is num) {
            return (json['profileCompletion'] as num).toInt();
          } else if (json['profileCompletion'] is String) {
            return int.tryParse(json['profileCompletion']) ?? 0;
          }
        }
        return 0;
      }(),
      skillMatchScore: () {
        if (json['skillMatchScore'] != null) {
          if (json['skillMatchScore'] is num) {
            return (json['skillMatchScore'] as num).toDouble();
          } else if (json['skillMatchScore'] is String) {
            return double.tryParse(json['skillMatchScore']) ?? 0.0;
          }
        }
        return 0.0;
      }(),
      cvUrl: json['cvUrl']?.toString(),
      cvFileName: json['cvFileName']?.toString(),
      cvUploadedAt: json['cvUploadedAt'] != null
          ? DateTime.tryParse(json['cvUploadedAt'].toString())
          : null,
      skills: () {
        if (json['skills'] != null) {
          try {
            if (json['skills'] is List) {
              return List<String>.from(
                (json['skills'] as List)
                    .where((s) => s != null)
                    .map((s) => s.toString()),
              );
            }
          } catch (e) {
            print('Error parsing skills: $e');
          }
        }
        return <String>[];
      }(),
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
      student: () {
        try {
          return Student.fromJson(json['student'] ?? {});
        } catch (e) {
          print('Error parsing student: $e');
          return Student(
            id: '',
            name: 'Unknown',
            email: '',
            profileCompletion: 0,
            skillMatchScore: 0.0,
          );
        }
      }(),
      topMatchedJobs: () {
        try {
          if (json['topMatchedJobs'] != null &&
              json['topMatchedJobs'] is List) {
            return (json['topMatchedJobs'] as List)
                .map((j) {
                  try {
                    return Job.fromJson(j);
                  } catch (e) {
                    print('Error parsing job: $e');
                    return null;
                  }
                })
                .where((j) => j != null)
                .cast<Job>()
                .toList();
          }
        } catch (e) {
          print('Error parsing topMatchedJobs: $e');
        }
        return <Job>[];
      }(),
      totalJobMatches: () {
        if (json['totalJobMatches'] != null) {
          if (json['totalJobMatches'] is num) {
            return (json['totalJobMatches'] as num).toInt();
          } else if (json['totalJobMatches'] is String) {
            return int.tryParse(json['totalJobMatches']) ?? 0;
          }
        }
        return 0;
      }(),
      skillsCount: () {
        if (json['skillsCount'] != null) {
          if (json['skillsCount'] is num) {
            return (json['skillsCount'] as num).toInt();
          } else if (json['skillsCount'] is String) {
            return int.tryParse(json['skillsCount']) ?? 0;
          }
        }
        return 0;
      }(),
    );
  }
}
