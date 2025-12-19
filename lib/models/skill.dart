class Skill {
  final String name;
  final String category; // Technical, Soft
  final String level; // Beginner, Intermediate, Advanced
  final String? explanation;
  final double proficiency; // 0-100
  
  Skill({
    required this.name,
    required this.category,
    required this.level,
    this.explanation,
    required this.proficiency,
  });
  
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] ?? '',
      category: json['category'] ?? 'Technical',
      level: json['level'] ?? 'Beginner',
      explanation: json['explanation'],
      proficiency: (json['proficiency'] ?? 0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'level': level,
      'explanation': explanation,
      'proficiency': proficiency,
    };
  }
}

class SkillAnalysis {
  final List<Skill> technicalSkills;
  final List<Skill> softSkills;
  final int totalSkills;
  final DateTime analyzedAt;
  
  SkillAnalysis({
    required this.technicalSkills,
    required this.softSkills,
    required this.totalSkills,
    required this.analyzedAt,
  });
  
  factory SkillAnalysis.fromJson(Map<String, dynamic> json) {
    return SkillAnalysis(
      technicalSkills: json['technicalSkills'] != null
          ? (json['technicalSkills'] as List).map((s) => Skill.fromJson(s)).toList()
          : [],
      softSkills: json['softSkills'] != null
          ? (json['softSkills'] as List).map((s) => Skill.fromJson(s)).toList()
          : [],
      totalSkills: json['totalSkills'] ?? 0,
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'])
          : DateTime.now(),
    );
  }
}

class SkillGap {
  final String jobId;
  final String jobTitle;
  final List<SkillComparison> skillComparisons;
  final List<String> missingSkills;
  final double overallMatch;
  final List<String> improvementSuggestions;
  
  SkillGap({
    required this.jobId,
    required this.jobTitle,
    required this.skillComparisons,
    required this.missingSkills,
    required this.overallMatch,
    required this.improvementSuggestions,
  });
  
  factory SkillGap.fromJson(Map<String, dynamic> json) {
    return SkillGap(
      jobId: json['jobId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      skillComparisons: json['skillComparisons'] != null
          ? (json['skillComparisons'] as List)
              .map((s) => SkillComparison.fromJson(s))
              .toList()
          : [],
      missingSkills: json['missingSkills'] != null
          ? List<String>.from(json['missingSkills'])
          : [],
      overallMatch: (json['overallMatch'] ?? 0).toDouble(),
      improvementSuggestions: json['improvementSuggestions'] != null
          ? List<String>.from(json['improvementSuggestions'])
          : [],
    );
  }
}

class SkillComparison {
  final String skillName;
  final double requiredLevel;
  final double currentLevel;
  final bool hasSkill;
  
  SkillComparison({
    required this.skillName,
    required this.requiredLevel,
    required this.currentLevel,
    required this.hasSkill,
  });
  
  factory SkillComparison.fromJson(Map<String, dynamic> json) {
    return SkillComparison(
      skillName: json['skillName'] ?? '',
      requiredLevel: (json['requiredLevel'] ?? json['required'] ?? 0).toDouble(),
      currentLevel: (json['currentLevel'] ?? json['current'] ?? 0).toDouble(),
      hasSkill: json['hasSkill'] ?? false,
    );
  }
}
