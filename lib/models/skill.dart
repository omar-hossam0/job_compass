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
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? 'Technical').toString(),
      level: (json['level'] ?? 'Beginner').toString(),
      explanation: json['explanation']?.toString(),
      proficiency: () {
        if (json['proficiency'] != null) {
          if (json['proficiency'] is num) {
            return (json['proficiency'] as num).toDouble();
          } else if (json['proficiency'] is String) {
            return double.tryParse(json['proficiency']) ?? 0.0;
          }
        }
        return 0.0;
      }(),
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
      technicalSkills: () {
        try {
          if (json['technicalSkills'] != null &&
              json['technicalSkills'] is List) {
            return (json['technicalSkills'] as List)
                .map((s) {
                  try {
                    return Skill.fromJson(s);
                  } catch (e) {
                    print('Error parsing technical skill: $e');
                    return null;
                  }
                })
                .where((s) => s != null)
                .cast<Skill>()
                .toList();
          }
        } catch (e) {
          print('Error parsing technicalSkills: $e');
        }
        return <Skill>[];
      }(),
      softSkills: () {
        try {
          if (json['softSkills'] != null && json['softSkills'] is List) {
            return (json['softSkills'] as List)
                .map((s) {
                  try {
                    return Skill.fromJson(s);
                  } catch (e) {
                    print('Error parsing soft skill: $e');
                    return null;
                  }
                })
                .where((s) => s != null)
                .cast<Skill>()
                .toList();
          }
        } catch (e) {
          print('Error parsing softSkills: $e');
        }
        return <Skill>[];
      }(),
      totalSkills: () {
        if (json['totalSkills'] != null) {
          if (json['totalSkills'] is num) {
            return (json['totalSkills'] as num).toInt();
          } else if (json['totalSkills'] is String) {
            return int.tryParse(json['totalSkills']) ?? 0;
          }
        }
        return 0;
      }(),
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.tryParse(json['analyzedAt'].toString()) ?? DateTime.now()
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
      jobId: (json['jobId'] ?? '').toString(),
      jobTitle: (json['jobTitle'] ?? '').toString(),
      skillComparisons: () {
        try {
          if (json['skillComparisons'] != null &&
              json['skillComparisons'] is List) {
            return (json['skillComparisons'] as List)
                .map((s) {
                  try {
                    return SkillComparison.fromJson(s);
                  } catch (e) {
                    print('Error parsing skill comparison: $e');
                    return null;
                  }
                })
                .where((s) => s != null)
                .cast<SkillComparison>()
                .toList();
          }
        } catch (e) {
          print('Error parsing skillComparisons: $e');
        }
        return <SkillComparison>[];
      }(),
      missingSkills: () {
        try {
          if (json['missingSkills'] != null && json['missingSkills'] is List) {
            return List<String>.from(
              (json['missingSkills'] as List)
                  .where((s) => s != null)
                  .map((s) => s.toString()),
            );
          }
        } catch (e) {
          print('Error parsing missingSkills: $e');
        }
        return <String>[];
      }(),
      overallMatch: () {
        if (json['overallMatch'] != null) {
          if (json['overallMatch'] is num) {
            return (json['overallMatch'] as num).toDouble();
          } else if (json['overallMatch'] is String) {
            return double.tryParse(json['overallMatch']) ?? 0.0;
          }
        }
        return 0.0;
      }(),
      improvementSuggestions: () {
        try {
          if (json['improvementSuggestions'] != null &&
              json['improvementSuggestions'] is List) {
            return List<String>.from(
              (json['improvementSuggestions'] as List)
                  .where((s) => s != null)
                  .map((s) => s.toString()),
            );
          }
        } catch (e) {
          print('Error parsing improvementSuggestions: $e');
        }
        return <String>[];
      }(),
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
      skillName: (json['skillName'] ?? '').toString(),
      requiredLevel: () {
        final val = json['requiredLevel'] ?? json['required'];
        if (val is num) {
          return val.toDouble();
        } else if (val is String) {
          return double.tryParse(val) ?? 0.0;
        }
        return 0.0;
      }(),
      currentLevel: () {
        final val = json['currentLevel'] ?? json['current'];
        if (val is num) {
          return val.toDouble();
        } else if (val is String) {
          return double.tryParse(val) ?? 0.0;
        }
        return 0.0;
      }(),
      hasSkill: () {
        final val = json['hasSkill'];
        if (val is bool) return val;
        if (val is String) return val.toLowerCase() == 'true';
        return false;
      }(),
    );
  }
}
