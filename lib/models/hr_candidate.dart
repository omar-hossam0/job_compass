class ScreeningAnswer {
  final String question;
  final String answer;

  ScreeningAnswer({required this.question, required this.answer});

  factory ScreeningAnswer.fromJson(Map<String, dynamic> json) {
    return ScreeningAnswer(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class BasicInfo {
  final String fullName;
  final String phoneNumber;
  final String region;
  final String address;
  final double expectedSalary;

  BasicInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.region,
    required this.address,
    required this.expectedSalary,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      region: json['region'] ?? '',
      address: json['address'] ?? '',
      expectedSalary: (json['expectedSalary'] ?? 0).toDouble(),
    );
  }
}

class HRCandidate {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? cvText;
  final String? cvUrl;
  final String? cvFileName;
  final List<String> extractedSkills;
  final double matchPercentage;
  final String? matchExplanation;
  final String? profilePicture;
  final DateTime? appliedAt;
  final String? applicationStatus;
  final BasicInfo? basicInfo;
  final List<ScreeningAnswer> screeningAnswers;
  final String? hrNotes;

  HRCandidate({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cvText,
    this.cvUrl,
    this.cvFileName,
    required this.extractedSkills,
    required this.matchPercentage,
    this.matchExplanation,
    this.profilePicture,
    this.appliedAt,
    this.applicationStatus,
    this.basicInfo,
    required this.screeningAnswers,
    this.hrNotes,
  });

  factory HRCandidate.fromJson(Map<String, dynamic> json) {
    return HRCandidate(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      cvText: json['cvText'],
      cvUrl: json['cvUrl'],
      cvFileName: json['cvFileName'],
      extractedSkills: json['extractedSkills'] != null
          ? List<String>.from(json['extractedSkills'])
          : [],
      matchPercentage: (json['matchPercentage'] ?? 0).toDouble(),
      matchExplanation: json['matchExplanation'],
      profilePicture: json['profilePicture'],
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'])
          : null,
      applicationStatus: json['applicationStatus'],
      basicInfo: json['basicInfo'] != null
          ? BasicInfo.fromJson(json['basicInfo'])
          : null,
      screeningAnswers: json['screeningAnswers'] != null
          ? (json['screeningAnswers'] as List)
                .map((a) => ScreeningAnswer.fromJson(a))
                .toList()
          : [],
      hrNotes: json['hrNotes'],
    );
  }
}
