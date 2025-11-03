import 'package:flutter/material.dart';

class InterviewAssistantScreen extends StatefulWidget {
  const InterviewAssistantScreen({super.key});

  @override
  State<InterviewAssistantScreen> createState() =>
      _InterviewAssistantScreenState();
}

class _InterviewAssistantScreenState extends State<InterviewAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'I\'m a UI/UX Designer. Could you find out a UI/UX job for me?',
        isBot: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );
    _messages.add(
      ChatMessage(
        text:
            'Thanks for asking. I\'ll try to find out a job for you. Could you send me your Portfolio & LinkedIn account?',
        isBot: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    );
    _messages.add(
      ChatMessage(
        text:
            'Portfolio Link : https://www.behance.net/gallery/187485347/Smart-Plates-AI-generator-Meal-planner-Mobile-App',
        isBot: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    );
    _messages.add(
      ChatMessage(
        text:
            'LinkedIn Link : https://www.behance.net/gallery/187485347/Smart-Plates-AI-generator-Meal-planner-Mobile-App',
        isBot: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isBot: false, timestamp: DateTime.now()),
      );
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Great! I\'ll review your portfolio and find the best jobs for you.',
            isBot: true,
            timestamp: DateTime.now(),
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff0f172a), Color(0xff1e293b)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(padding.clamp(12.0, 20.0)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: padding.clamp(12.0, 20.0),
                    vertical: 8,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding.clamp(16.0, 24.0),
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(true),
                    const SizedBox(width: 4),
                    _buildDot(true),
                    const SizedBox(width: 4),
                    _buildDot(true),
                    const SizedBox(width: 4),
                    _buildDot(false),
                    const SizedBox(width: 4),
                    _buildDot(false),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(padding.clamp(12.0, 20.0)),
                padding: EdgeInsets.symmetric(
                  horizontal: padding.clamp(12.0, 20.0),
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff1e293b),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff3b82f6), Color(0xff8b5cf6)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xff3b82f6) : Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isBot) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xff3b82f6),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isBot
                    ? const Color(0xff1e293b).withOpacity(0.6)
                    : const Color(0xff3b82f6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isBot ? 4 : 20),
                  bottomRight: Radius.circular(message.isBot ? 20 : 4),
                ),
                border: message.isBot
                    ? Border.all(color: Colors.white.withOpacity(0.1))
                    : null,
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!message.isBot) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}
