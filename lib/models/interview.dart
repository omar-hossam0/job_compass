class InterviewSession {
  final String id;
  final String studentId;
  final String jobTitle;
  final List<InterviewQuestion> questions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final InterviewFeedback? feedback;
  
  InterviewSession({
    required this.id,
    required this.studentId,
    required this.jobTitle,
    required this.questions,
    required this.startedAt,
    this.completedAt,
    this.feedback,
  });
  
  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: json['id'] ?? json['_id'] ?? '',
      studentId: json['studentId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => InterviewQuestion.fromJson(q))
              .toList()
          : [],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      feedback: json['feedback'] != null
          ? InterviewFeedback.fromJson(json['feedback'])
          : null,
    );
  }
}

class InterviewQuestion {
  final String question;
  final String? answer;
  final String? aiResponse;
  final int? rating; // 1-5
  
  InterviewQuestion({
    required this.question,
    this.answer,
    this.aiResponse,
    this.rating,
  });
  
  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: json['question'] ?? '',
      answer: json['answer'],
      aiResponse: json['aiResponse'],
      rating: json['rating'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'aiResponse': aiResponse,
      'rating': rating,
    };
  }
}

class InterviewFeedback {
  final List<String> strengths;
  final List<String> weaknesses;
  final double overallScore;
  final String summary;
  
  InterviewFeedback({
    required this.strengths,
    required this.weaknesses,
    required this.overallScore,
    required this.summary,
  });
  
  factory InterviewFeedback.fromJson(Map<String, dynamic> json) {
    return InterviewFeedback(
      strengths: json['strengths'] != null
          ? List<String>.from(json['strengths'])
          : [],
      weaknesses: json['weaknesses'] != null
          ? List<String>.from(json['weaknesses'])
          : [],
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      summary: json['summary'] ?? '',
    );
  }
}
