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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? 'candidate').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      isMe: () {
        final isMe = json['isMe'];
        if (isMe is bool) return isMe;
        if (isMe is String) return isMe.toLowerCase() == 'true';
        return false;
      }(),
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      candidateId: (json['candidateId'] ?? '').toString(),
      candidateName: (json['candidateName'] ?? 'Unknown').toString(),
      candidatePhoto: json['candidatePhoto']?.toString(),
      jobId: (json['jobId'] ?? '').toString(),
      jobTitle: (json['jobTitle'] ?? 'Unknown Job').toString(),
      hrId: json['hrId']?.toString(),
      hrName: json['hrName']?.toString(),
      hrPhoto: json['hrPhoto']?.toString(),
      messages: () {
        try {
          if (json['messages'] != null && json['messages'] is List) {
            return (json['messages'] as List)
                .map((m) {
                  try {
                    return ChatMessage.fromJson(m);
                  } catch (e) {
                    print('Error parsing message: $e');
                    return null;
                  }
                })
                .where((m) => m != null)
                .cast<ChatMessage>()
                .toList();
          }
        } catch (e) {
          print('Error parsing messages: $e');
        }
        return <ChatMessage>[];
      }(),
      status: (json['status'] ?? 'active').toString(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      candidateId: (json['candidateId'] ?? '').toString(),
      candidateName: (json['candidateName'] ?? 'Unknown').toString(),
      candidatePhoto: json['candidatePhoto']?.toString(),
      hrId: json['hrId']?.toString(),
      hrName: json['hrName']?.toString(),
      hrPhoto: json['hrPhoto']?.toString(),
      jobId: (json['jobId'] ?? '').toString(),
      jobTitle: (json['jobTitle'] ?? 'Unknown Job').toString(),
      companyLogo: json['companyLogo']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      unreadCount: () {
        if (json['unreadCount'] != null) {
          if (json['unreadCount'] is num) {
            return (json['unreadCount'] as num).toInt();
          } else if (json['unreadCount'] is String) {
            return int.tryParse(json['unreadCount']) ?? 0;
          }
        }
        return 0;
      }(),
      status: (json['status'] ?? 'active').toString(),
    );
  }
}
