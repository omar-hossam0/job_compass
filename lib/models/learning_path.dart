class LearningPath {
  final String id;
  final String studentId;
  final List<LearningModule> modules;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  LearningPath({
    required this.id,
    required this.studentId,
    required this.modules,
    required this.createdAt,
    this.lastUpdated,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      studentId: (json['studentId'] ?? '').toString(),
      modules: () {
        try {
          if (json['modules'] != null && json['modules'] is List) {
            return (json['modules'] as List)
                .map((m) {
                  try {
                    return LearningModule.fromJson(m);
                  } catch (e) {
                    print('Error parsing module: $e');
                    return null;
                  }
                })
                .where((m) => m != null)
                .cast<LearningModule>()
                .toList();
          }
        } catch (e) {
          print('Error parsing modules: $e');
        }
        return <LearningModule>[];
      }(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString())
          : null,
    );
  }
}

class LearningModule {
  final String id;
  final String skillName;
  final String weekLabel; // "Week 1", "Week 2", etc.
  final String level; // Beginner, Intermediate, Advanced
  final List<Course> courses;
  final bool isCompleted;

  LearningModule({
    required this.id,
    required this.skillName,
    required this.weekLabel,
    required this.level,
    required this.courses,
    this.isCompleted = false,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      skillName: (json['skillName'] ?? '').toString(),
      weekLabel: (json['weekLabel'] ?? '').toString(),
      level: (json['level'] ?? 'Beginner').toString(),
      courses: () {
        try {
          if (json['courses'] != null && json['courses'] is List) {
            return (json['courses'] as List)
                .map((c) {
                  try {
                    return Course.fromJson(c);
                  } catch (e) {
                    print('Error parsing course: $e');
                    return null;
                  }
                })
                .where((c) => c != null)
                .cast<Course>()
                .toList();
          }
        } catch (e) {
          print('Error parsing courses: $e');
        }
        return <Course>[];
      }(),
      isCompleted: () {
        final val = json['isCompleted'];
        if (val is bool) return val;
        if (val is String) return val.toLowerCase() == 'true';
        return false;
      }(),
    );
  }
}

class Course {
  final String title;
  final String platform; // YouTube, Coursera, Udemy
  final String url;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int durationMinutes;
  final String? thumbnail;

  Course({
    required this.title,
    required this.platform,
    required this.url,
    required this.difficulty,
    required this.durationMinutes,
    this.thumbnail,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: (json['title'] ?? '').toString(),
      platform: (json['platform'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? 'Beginner').toString(),
      durationMinutes: () {
        if (json['durationMinutes'] != null) {
          if (json['durationMinutes'] is num) {
            return (json['durationMinutes'] as num).toInt();
          } else if (json['durationMinutes'] is String) {
            return int.tryParse(json['durationMinutes']) ?? 0;
          }
        }
        return 0;
      }(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
