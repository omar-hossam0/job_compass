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
      id: json['id'] ?? json['_id'] ?? '',
      studentId: json['studentId'] ?? '',
      modules: json['modules'] != null
          ? (json['modules'] as List)
                .map((m) => LearningModule.fromJson(m))
                .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
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
      id: json['id'] ?? json['_id'] ?? '',
      skillName: json['skillName'] ?? '',
      weekLabel: json['weekLabel'] ?? '',
      level: json['level'] ?? 'Beginner',
      courses: json['courses'] != null
          ? (json['courses'] as List).map((c) => Course.fromJson(c)).toList()
          : [],
      isCompleted: json['isCompleted'] ?? false,
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
      title: json['title'] ?? '',
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      durationMinutes: json['durationMinutes'] ?? 0,
      thumbnail: json['thumbnail'],
    );
  }
}
