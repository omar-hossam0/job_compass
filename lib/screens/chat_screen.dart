import 'package:flutter/material.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _addInitialMessages();
  }

  void _addInitialMessages() {
    setState(() {
      _messages.addAll([
        {
          'text': 'Hi! 👋 Welcome to Job Compass Interview Assistant',
          'isBotMessage': true,
          'timestamp': DateTime.now(),
        },
        {
          'text':
              'I\'m here to help you prepare for your interviews. What would you like to know?',
          'isBotMessage': true,
          'timestamp': DateTime.now(),
        },
      ]);
    });
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({
        'text': text,
        'isBotMessage': false,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response with delay
    Timer(const Duration(milliseconds: 800), () {
      _handleBotResponse(text);
    });
  }

  void _handleBotResponse(String userMessage) {
    String botResponse = '';

    if (userMessage.toLowerCase().contains('interview')) {
      botResponse =
          'Great! I can help you prepare for interviews. Would you like tips on:\n\n• Common interview questions\n• Technical preparation\n• Behavioral questions\n• Salary negotiation';
    } else if (userMessage.toLowerCase().contains('question')) {
      botResponse =
          'Here are some common interview questions:\n\n1. "Tell me about yourself"\n2. "Why do you want this job?"\n3. "What are your strengths?"\n4. "How do you handle stress?"\n\nWould you like detailed answers for any of these?';
    } else if (userMessage.toLowerCase().contains('technical')) {
      botResponse =
          'For technical preparation:\n\n✓ Review core concepts\n✓ Practice coding problems\n✓ Study design patterns\n✓ Prepare system design scenarios\n\nWhat technology are you focusing on?';
    } else if (userMessage.toLowerCase().contains('salary')) {
      botResponse =
          'Salary negotiation tips:\n\n💡 Research market rates\n💡 Know your worth\n💡 Practice your pitch\n💡 Be confident but flexible\n\nWould you like specific advice?';
    } else if (userMessage.toLowerCase().contains('feedback')) {
      botResponse =
          'Ask the interviewer for feedback:\n\n"Thank you for your time. Do you have any feedback on my performance?"\n\nThis shows confidence and interest in improvement!';
    } else if (userMessage.toLowerCase().contains('thank')) {
      botResponse =
          'You\'re welcome! Remember: preparation is key to success. Good luck with your interviews! 🚀';
    } else if (userMessage.toLowerCase().contains('hi') ||
        userMessage.toLowerCase().contains('hello')) {
      botResponse =
          'Hi there! 👋 How can I help you prepare for your interview today?';
    } else if (userMessage.toLowerCase().contains('help')) {
      botResponse =
          'I can assist with:\n\n📚 Interview tips & tricks\n❓ Common question answers\n💼 Company research\n🎯 Interview strategies\n📝 Resume advice\n\nWhat interests you?';
    } else {
      botResponse =
          'That\'s a great question! To help you better, you could ask me about:\n\n• Interview preparation\n• Technical questions\n• Behavioral questions\n• Salary negotiation\n• Company research\n\nWhich area would help you most?';
    }

    setState(() {
      _messages.add({
        'text': botResponse,
        'isBotMessage': true,
        'timestamp': DateTime.now(),
      });
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F5),
        elevation: 0,
        title: const Text(
          'Interview Assistant',
          style: TextStyle(
            color: Color(0xff070C19),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xff070C19),
              size: 20,
            ),
          ),
        ),
        centerTitle: false,
        leadingWidth: 40,
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'] as String,
                  message['isBotMessage'] as bool,
                );
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask something...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xff3F6CDF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
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
    );
  }

  Widget _buildMessageBubble(String text, bool isBotMessage) {
    return Align(
      alignment: isBotMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isBotMessage
              ? Colors.white
              : const Color(0xff3F6CDF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBotMessage ? const Color(0xff070C19) : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
