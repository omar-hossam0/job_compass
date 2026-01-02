class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole; // 'hr' or 'candidate'
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderRole: json['senderRole'] ?? 'candidate',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : null,
      isMe: json['isMe'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderRole': senderRole,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isMe': isMe,
    };
  }
}

class Chat {
  final String id;
  final String candidateId;
  final String candidateName;
  final String? candidatePhoto;
  final String jobId;
  final String jobTitle;
  final String? hrId;
  final String? hrName;
  final String? hrPhoto;
  final List<ChatMessage> messages;
  final String status;
  final DateTime? lastMessageAt;

  Chat({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    this.candidatePhoto,
    required this.jobId,
    required this.jobTitle,
    this.hrId,
    this.hrName,
    this.hrPhoto,
    this.messages = const [],
    this.status = 'active',
    this.lastMessageAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      candidateName: json['candidateName'] ?? 'Unknown',
      candidatePhoto: json['candidatePhoto'],
      jobId: json['jobId']?.toString() ?? '',
      jobTitle: json['jobTitle'] ?? 'Unknown Job',
      hrId: json['hrId']?.toString(),
      hrName: json['hrName'],
      hrPhoto: json['hrPhoto'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessage.fromJson(m))
          .toList() ?? [],
      status: json['status'] ?? 'active',
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']) 
          : null,
    );
  }
}

class ChatPreview {
  final String id;
  final String candidateId;
  final String candidateName;
  final String? candidatePhoto;
  final String? hrId;
  final String? hrName;
  final String? hrPhoto;
  final String jobId;
  final String jobTitle;
  final String? companyLogo;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String status;

  ChatPreview({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    this.candidatePhoto,
    this.hrId,
    this.hrName,
    this.hrPhoto,
    required this.jobId,
    required this.jobTitle,
    this.companyLogo,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.status = 'active',
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      id: json['id']?.toString() ?? '',
      candidateId: json['candidateId']?.toString() ?? '',
      candidateName: json['candidateName'] ?? 'Unknown',
      candidatePhoto: json['candidatePhoto'],
      hrId: json['hrId']?.toString(),
      hrName: json['hrName'],
      hrPhoto: json['hrPhoto'],
      jobId: json['jobId']?.toString() ?? '',
      jobTitle: json['jobTitle'] ?? 'Unknown Job',
      companyLogo: json['companyLogo'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      status: json['status'] ?? 'active',
    );
  }
}
