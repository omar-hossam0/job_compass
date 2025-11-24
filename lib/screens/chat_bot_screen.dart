import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(ChatMessage(
      text: "Hello! I'm your Job Compass assistant. Ask me anything about jobs, applications, or career advice!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Call OpenAI API (you can replace with any other AI API)
      final response = await _getAIResponse(message);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I'm having trouble connecting. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _getAIResponse(String message) async {
    // Using a free AI API - you can replace this with OpenAI, Gemini, or any other API
    // For demo purposes, using a mock response system
    
    // TODO: Replace with your actual API key and endpoint
    // Example with OpenAI:
    /*
    final apiKey = 'YOUR_OPENAI_API_KEY';
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful job search assistant. Help users with job-related questions, career advice, and application tips.'
          },
          {'role': 'user', 'content': message}
        ],
        'max_tokens': 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    }
    */

    // Mock response for demo (remove this when using real API)
    await Future.delayed(const Duration(seconds: 2));
    return _getMockResponse(message);
  }

  String _getMockResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Greetings
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || 
        lowerMessage.contains('hey') || lowerMessage.contains('السلام') ||
        lowerMessage.contains('مرحبا') || lowerMessage.contains('أهلا')) {
      return "Hello! 👋 I'm your Job Compass assistant. I'm here to help you with:\n\n• Finding the right job\n• Interview preparation\n• Resume/CV advice\n• Career guidance\n• Salary negotiation\n• Professional development\n\nWhat would you like to know today?";
    }

    // Job search and opportunities
    if (lowerMessage.contains('job') || lowerMessage.contains('position') || 
        lowerMessage.contains('وظيفة') || lowerMessage.contains('عمل')) {
      return "Great! Let me help you with job opportunities:\n\n🔍 **Finding Jobs:**\n• Browse our listings by category\n• Use filters for location, salary, type\n• Check 'Best Matches' for personalized recommendations\n\n💼 **Available Roles:**\nWe have openings in:\n• UI/UX Design\n• Software Engineering\n• Product Management\n• Data Science\n• Marketing\n• Sales\n\nWould you like to search for a specific role or industry?";
    }

    // Application process
    if (lowerMessage.contains('apply') || lowerMessage.contains('application') ||
        lowerMessage.contains('تقديم') || lowerMessage.contains('submit')) {
      return "📝 **Application Process Guide:**\n\n**Step 1:** Browse jobs and find your match\n**Step 2:** Click 'Apply Now' on the job listing\n**Step 3:** Fill in your personal information\n**Step 4:** Upload your CV (PDF, DOC, or DOCX)\n**Step 5:** Write a cover letter (optional but recommended)\n**Step 6:** Submit!\n\n✨ **Pro Tips:**\n• Tailor your CV to each position\n• Highlight relevant achievements\n• Proofread everything\n• Apply as soon as possible\n\nNeed help with a specific part of the application?";
    }

    // CV/Resume advice
    if (lowerMessage.contains('cv') || lowerMessage.contains('resume') ||
        lowerMessage.contains('السيرة الذاتية') || lowerMessage.contains('portfolio')) {
      return "📄 **CV/Resume Excellence Guide:**\n\n**Structure:**\n1. Contact Info (name, email, phone, LinkedIn)\n2. Professional Summary (2-3 lines)\n3. Work Experience (most recent first)\n4. Education\n5. Skills\n6. Certifications/Awards\n\n**Best Practices:**\n✓ Keep it 1-2 pages\n✓ Use bullet points\n✓ Quantify achievements (e.g., 'Increased sales by 30%')\n✓ Use action verbs (led, developed, managed)\n✓ Customize for each job\n✓ No typos or grammar errors!\n\n**What to Avoid:**\n✗ Generic objectives\n✗ Irrelevant information\n✗ Lies or exaggerations\n✗ Poor formatting\n\nWant specific advice for your industry?";
    }

    // Interview preparation
    if (lowerMessage.contains('interview') || lowerMessage.contains('مقابلة') ||
        lowerMessage.contains('meeting')) {
      return "🎯 **Interview Preparation Masterclass:**\n\n**Before the Interview:**\n• Research the company thoroughly\n• Review the job description\n• Prepare STAR stories (Situation, Task, Action, Result)\n• Prepare questions to ask them\n• Test your tech setup (for virtual interviews)\n\n**Common Questions & How to Answer:**\n\n1️⃣ 'Tell me about yourself'\n→ 30-second pitch: background, current role, why interested\n\n2️⃣ 'Why do you want this job?'\n→ Show passion + how it aligns with your goals\n\n3️⃣ 'What's your weakness?'\n→ Real weakness + how you're improving it\n\n4️⃣ 'Where do you see yourself in 5 years?'\n→ Show ambition + commitment to growth\n\n**During the Interview:**\n✓ Make eye contact\n✓ Smile and be confident\n✓ Listen carefully\n✓ Take a moment to think\n✓ Ask for clarification if needed\n\n**After:**\n• Send thank-you email within 24 hours\n• Reference specific discussion points\n\nNeed more specific interview tips?";
    }

    // Salary and negotiation
    if (lowerMessage.contains('salary') || lowerMessage.contains('pay') ||
        lowerMessage.contains('راتب') || lowerMessage.contains('negotiate') ||
        lowerMessage.contains('compensation')) {
      return "💰 **Salary Negotiation Guide:**\n\n**Research First:**\n• Check industry standards (Glassdoor, PayScale)\n• Consider: location, experience, company size\n• Know your worth!\n\n**When to Negotiate:**\n✓ After receiving an offer\n✓ During performance reviews\n✓ When taking on new responsibilities\n\n**How to Negotiate:**\n\n1. **Wait for them to mention numbers first**\n2. **Express enthusiasm** for the role\n3. **Provide your range** based on research\n4. **Highlight your value** (skills, experience, achievements)\n5. **Be flexible** - consider total package (benefits, WFH, vacation)\n6. **Get it in writing**\n\n**Example Script:**\n'I'm very excited about this opportunity. Based on my research and experience, I was expecting a salary in the range of \$X-\$Y. Given my skills in [specific areas], I believe this is fair. Is there flexibility in the offer?'\n\n**Remember:**\n• Companies expect negotiation\n• Worst they can say is no\n• Stay professional and positive\n\nWant tips for a specific salary range or industry?";
    }

    // Remote work
    if (lowerMessage.contains('remote') || lowerMessage.contains('work from home') ||
        lowerMessage.contains('wfh') || lowerMessage.contains('hybrid') ||
        lowerMessage.contains('بعد') || lowerMessage.contains('online')) {
      return "🏠 **Remote Work Opportunities & Tips:**\n\n**Finding Remote Jobs:**\n• Use our 'Remote' filter in job search\n• Many tech, design, and writing roles available\n• Growing trend in all industries!\n\n**Remote Work Benefits:**\n✓ No commute time\n✓ Flexible schedule\n✓ Work from anywhere\n✓ Better work-life balance\n✓ Cost savings\n\n**Succeeding in Remote Work:**\n• Create a dedicated workspace\n• Set clear boundaries\n• Over-communicate with team\n• Use productivity tools\n• Take regular breaks\n• Stay connected with colleagues\n\n**Common Concerns:**\n❓ Will I be less visible?\n→ Schedule regular check-ins, document your work\n\n❓ How do I stay motivated?\n→ Set daily goals, maintain routine, join virtual coworking\n\n❓ What about career growth?\n→ Take online courses, network virtually, seek feedback\n\nInterested in hybrid or fully remote positions?";
    }

    // Career change
    if (lowerMessage.contains('career change') || lowerMessage.contains('switch') ||
        lowerMessage.contains('transition') || lowerMessage.contains('تغيير')) {
      return "🔄 **Career Change Strategy:**\n\n**1. Self-Assessment:**\n• What do you enjoy doing?\n• What are your transferable skills?\n• What's your 'why' for changing?\n\n**2. Research New Field:**\n• Job requirements\n• Salary expectations\n• Growth potential\n• Day-to-day reality\n\n**3. Bridge the Gap:**\n• Online courses (Coursera, Udemy, LinkedIn Learning)\n• Side projects\n• Freelancing\n• Networking in new industry\n• Informational interviews\n\n**4. Update Your Materials:**\n• Reframe your experience\n• Highlight transferable skills\n• Show passion for new field\n• Get relevant certifications\n\n**5. Start Strategic Job Search:**\n• Entry-level in new field\n• Companies that value your background\n• Roles that blend old + new skills\n\n**Success Stories:**\nMany people successfully transition! Teachers → Trainers, Engineers → Product Managers, etc.\n\nWhat field are you considering?";
    }

    // Skills and learning
    if (lowerMessage.contains('skill') || lowerMessage.contains('learn') ||
        lowerMessage.contains('course') || lowerMessage.contains('تعلم') ||
        lowerMessage.contains('مهارة')) {
      return "📚 **Skills Development Guide:**\n\n**Most In-Demand Skills 2024:**\n\n🔥 **Tech Skills:**\n• Python, JavaScript, React\n• Data Analysis\n• Cloud Computing (AWS, Azure)\n• Cybersecurity\n• AI/Machine Learning basics\n\n💼 **Professional Skills:**\n• Project Management\n• Digital Marketing\n• UX/UI Design\n• Data Visualization\n• Business Analytics\n\n🌟 **Soft Skills:**\n• Communication\n• Leadership\n• Problem-solving\n• Adaptability\n• Emotional Intelligence\n\n**Where to Learn:**\n• **Free:** YouTube, freeCodeCamp, Khan Academy\n• **Affordable:** Udemy, Skillshare, Coursera\n• **Professional:** LinkedIn Learning, Pluralsight\n• **Certifications:** Google, AWS, HubSpot\n\n**Learning Strategy:**\n1. Choose 1-2 skills to focus on\n2. Set specific goals (e.g., build 3 projects)\n3. Practice daily (even 30 min)\n4. Build portfolio projects\n5. Get feedback from community\n\nWhat skill are you interested in developing?";
    }

    // Cover letter
    if (lowerMessage.contains('cover letter') || lowerMessage.contains('cover') ||
        lowerMessage.contains('خطاب') || lowerMessage.contains('motivation')) {
      return "✍️ **Cover Letter Writing Guide:**\n\n**Structure (3-4 paragraphs):**\n\n**1. Opening:**\n• Which position you're applying for\n• How you found it\n• Brief hook (your enthusiasm/achievement)\n\n**2. Why You're Perfect:**\n• 2-3 specific examples\n• Match your skills to job requirements\n• Use numbers/metrics when possible\n\n**3. Why This Company:**\n• Show you've researched them\n• Align with their values/mission\n• Mention specific projects/news\n\n**4. Closing:**\n• Express enthusiasm\n• Call to action\n• Thank them\n\n**Example Opening:**\n'I'm excited to apply for the UX Designer role at [Company]. With 5 years of experience designing user-centered products that increased engagement by 40%, I'm confident I can help [Company] achieve its mission of...'\n\n**Tips:**\n✓ Keep it under 1 page\n✓ Customize for each job\n✓ Show personality\n✓ Avoid repeating your resume\n✓ Proofread!\n\nNeed help with a specific section?";
    }

    // LinkedIn and networking
    if (lowerMessage.contains('linkedin') || lowerMessage.contains('network') ||
        lowerMessage.contains('connect') || lowerMessage.contains('شبكة')) {
      return "🤝 **LinkedIn & Networking Guide:**\n\n**Optimize Your LinkedIn:**\n\n📸 **Profile Photo:**\n• Professional headshot\n• Good lighting\n• Friendly smile\n\n📝 **Headline:**\n• More than job title\n• Example: 'UX Designer | Creating Intuitive Digital Experiences | Available for Freelance'\n\n📄 **Summary:**\n• Your story in 3-5 paragraphs\n• What you do + how you help\n• Call to action\n\n🎯 **Experience:**\n• Use bullet points\n• Start with action verbs\n• Include achievements\n\n**Networking Strategies:**\n\n1️⃣ **Connect Strategically:**\n• Add personal note\n• Connect with: colleagues, alumni, industry leaders\n\n2️⃣ **Engage with Content:**\n• Comment thoughtfully\n• Share valuable insights\n• Post 2-3 times per week\n\n3️⃣ **Send Informational Interview Requests:**\n'Hi [Name], I admire your work in [field]. Would you have 15 minutes for a quick call? I'd love to learn about your career path.'\n\n4️⃣ **Follow Up:**\n• After meeting someone\n• After interviews\n• Stay in touch periodically\n\n**Remember:** Networking is about building relationships, not just asking for jobs!\n\nWant specific networking tips?";
    }

    // Job offer evaluation
    if (lowerMessage.contains('offer') || lowerMessage.contains('accept') ||
        lowerMessage.contains('decline') || lowerMessage.contains('عرض')) {
      return "🎁 **Job Offer Evaluation Checklist:**\n\n**Financial Package:**\n💵 Base salary\n💰 Bonuses/commissions\n📈 Stock options/equity\n🎯 Performance incentives\n\n**Benefits:**\n🏥 Health insurance (coverage quality?)\n🦷 Dental & vision\n💼 401k/retirement matching\n🏖️ PTO days (how many?)\n😷 Sick leave\n👶 Parental leave\n📚 Professional development budget\n\n**Work Environment:**\n🏠 Remote/hybrid/office?\n⏰ Work hours flexibility\n👥 Team size and structure\n📊 Reporting structure\n🚀 Company culture\n📈 Growth opportunities\n\n**Career Growth:**\n📚 Training programs\n🎯 Clear career path\n👨‍🏫 Mentorship\n🔄 Internal mobility\n\n**Red Flags to Watch:**\n🚩 Unrealistic expectations\n🚩 High turnover rate\n🚩 Poor Glassdoor reviews\n🚩 Vague job responsibilities\n🚩 Pressure to accept quickly\n\n**Decision Framework:**\n1. Make a pros/cons list\n2. Compare to your must-haves\n3. Trust your gut feeling\n4. Negotiate if needed\n5. Ask for time to decide (3-7 days)\n\n**Questions to Ask:**\n• 'What does success look like in this role?'\n• 'What are the biggest challenges?'\n• 'How is performance measured?'\n\nNeed help evaluating a specific offer?";
    }

    // First day/week advice
    if (lowerMessage.contains('first day') || lowerMessage.contains('new job') ||
        lowerMessage.contains('start') || lowerMessage.contains('اول يوم')) {
      return "🎉 **First Day/Week Success Guide:**\n\n**Before Day 1:**\n• Confirm start time & location\n• Prepare questions\n• Review company info\n• Get good sleep!\n• Plan your outfit\n\n**First Day:**\n\n**Morning:**\n✓ Arrive 10-15 min early\n✓ Bring notebook & pen\n✓ Smile and introduce yourself\n✓ Take notes during orientation\n\n**Throughout:**\n✓ Ask questions\n✓ Remember names (write them down!)\n✓ Observe workplace culture\n✓ Set up your workspace\n✓ Learn key systems/tools\n\n**First Week Goals:**\n\n📝 **Learn:**\n• Team structure\n• Key processes\n• Company tools\n• Project priorities\n\n🤝 **Relationships:**\n• Schedule 1-on-1s with teammates\n• Find a buddy/mentor\n• Join team lunch/coffee\n\n🎯 **Quick Wins:**\n• Complete onboarding tasks\n• Contribute in meetings\n• Volunteer for small tasks\n\n**Do's:**\n✓ Be curious and eager\n✓ Take initiative\n✓ Be positive\n✓ Listen more than you speak\n✓ Follow up on action items\n\n**Don'ts:**\n✗ Compare to old job constantly\n✗ Be too opinionated too soon\n✗ Skip social events\n✗ Be afraid to ask for help\n\n**Remember:** Everyone expects you to have questions. It's OK not to know everything!\n\nNervous about something specific?";
    }

    // Work-life balance
    if (lowerMessage.contains('balance') || lowerMessage.contains('burnout') ||
        lowerMessage.contains('stress') || lowerMessage.contains('توازن')) {
      return "⚖️ **Work-Life Balance & Burnout Prevention:**\n\n**Warning Signs of Burnout:**\n😫 Constant exhaustion\n😤 Cynicism about work\n📉 Decreased productivity\n🤕 Physical symptoms\n😔 Loss of motivation\n\n**Setting Boundaries:**\n\n⏰ **Time Boundaries:**\n• Set work hours\n• Turn off notifications after hours\n• Use 'Do Not Disturb'\n• Take real lunch breaks\n\n🚫 **Learn to Say No:**\n'I'd love to help, but I'm at capacity. Can we revisit this next week?'\n\n**Daily Habits:**\n• Start with most important task\n• Time-block your calendar\n• Take short breaks (Pomodoro: 25 min work, 5 min break)\n• End day by planning tomorrow\n• Disconnect completely on weekends\n\n**Self-Care Practices:**\n🏃 Exercise (even 15 min)\n😴 7-9 hours sleep\n🧘 Meditation/mindfulness\n👥 Social connections\n🎨 Hobbies outside work\n🌳 Time in nature\n\n**When to Seek Help:**\n• Talk to manager about workload\n• Use employee assistance program\n• Consider therapy\n• Might be time for a change\n\n**Remember:** You're more than your job. Taking care of yourself makes you better at work!\n\nStruggling with something specific?";
    }

    // Portfolio advice
    if (lowerMessage.contains('portfolio') || lowerMessage.contains('project') ||
        lowerMessage.contains('showcase') || lowerMessage.contains('معرض')) {
      return "🎨 **Portfolio Building Guide:**\n\n**Portfolio Essentials:**\n\n**1. Homepage:**\n• Your name & title\n• Brief bio (2-3 sentences)\n• Your photo\n• Contact info\n• Call-to-action\n\n**2. Projects (3-6 best):**\n\nFor each project include:\n📋 **Context:** What was the challenge?\n🎯 **Your Role:** What did you do specifically?\n⚙️ **Process:** How did you approach it?\n✨ **Result:** Impact/metrics\n🖼️ **Visuals:** High-quality images\n\n**3. About Page:**\n• Your story\n• Your skills\n• What drives you\n• Downloadable resume\n\n**4. Contact:**\n• Email\n• LinkedIn\n• GitHub (for developers)\n• Social media\n\n**Quality > Quantity:**\n• Better to have 3 amazing projects than 10 mediocre ones\n• Show process, not just final result\n• Explain your thinking\n\n**Tips by Field:**\n\n💻 **Developers:**\n• GitHub repos with good READMEs\n• Live demos\n• Code snippets\n• Technical blog\n\n🎨 **Designers:**\n• Case studies\n• Before/after\n• Design thinking process\n• Prototypes\n\n✍️ **Writers:**\n• Best articles/samples\n• Variety of styles\n• Published work\n• Blog\n\n**Platforms:**\n• Personal website (best)\n• Behance/Dribbble (design)\n• GitHub Pages (dev)\n• Medium (writing)\n\n**Common Mistakes:**\n✗ No clear narrative\n✗ Poor quality images\n✗ Too much or too little\n✗ Outdated work\n✗ No contact info\n\nNeed specific portfolio advice?";
    }

    // General career advice
    if (lowerMessage.contains('career') || lowerMessage.contains('advice') ||
        lowerMessage.contains('guidance') || lowerMessage.contains('مهني') ||
        lowerMessage.contains('نصيحة') || lowerMessage.contains('help')) {
      return "🌟 **General Career Advice & Guidance:**\n\n**Career Development Pillars:**\n\n**1. Continuous Learning:**\n📚 Never stop developing skills\n🎓 Formal education + self-teaching\n👥 Learn from mentors\n🔄 Stay current with industry trends\n\n**2. Build Your Brand:**\n💼 Define your unique value\n🌐 Professional online presence\n📝 Share your knowledge\n🎯 Be known for something\n\n**3. Network Strategically:**\n🤝 Quality over quantity\n💡 Give before you ask\n🔗 Stay in touch\n📧 Follow up consistently\n\n**4. Take Calculated Risks:**\n🚀 Step outside comfort zone\n💪 Embrace challenges\n📈 See failures as learning\n🎯 Know when to pivot\n\n**5. Seek Feedback:**\n👂 Ask for honest input\n📊 Track your progress\n🔄 Iterate and improve\n🎓 Learn from mistakes\n\n**Career Milestones by Stage:**\n\n**Early Career (0-5 years):**\n• Learn everything\n• Build foundational skills\n• Find mentors\n• Explore different areas\n\n**Mid Career (5-15 years):**\n• Develop expertise\n• Take leadership roles\n• Build your network\n• Consider specialization\n\n**Senior Career (15+ years):**\n• Mentor others\n• Strategic thinking\n• Industry influence\n• Give back to community\n\n**Questions to Ask Yourself:**\n• Am I learning and growing?\n• Do I feel challenged?\n• Am I building valuable skills?\n• Does this align with my goals?\n• Am I happy?\n\n**Remember:** Career is a marathon, not a sprint. Progress isn't always linear!\n\nWhat specific aspect of your career would you like guidance on?";
    }

    // Thank you / goodbye
    if (lowerMessage.contains('thank') || lowerMessage.contains('thanks') ||
        lowerMessage.contains('شكرا') || lowerMessage.contains('bye') ||
        lowerMessage.contains('goodbye')) {
      return "You're very welcome! 😊 I'm here anytime you need help with:\n\n• Job search\n• Career advice\n• Interview prep\n• Resume tips\n• Professional development\n\nBest of luck with your career journey! Feel free to come back anytime. 🚀\n\n'The future belongs to those who believe in the beauty of their dreams.' - Eleanor Roosevelt";
    }

    // Default response for any other question
    return "I'm here to help with all your career questions! 💼\n\nI can assist you with:\n\n🔍 **Job Search:**\n• Finding opportunities\n• Understanding job descriptions\n• Application strategies\n\n📄 **Application Materials:**\n• Resume/CV writing\n• Cover letters\n• Portfolio building\n• LinkedIn optimization\n\n🎯 **Interview Preparation:**\n• Common questions\n• STAR method\n• Body language tips\n• Follow-up strategies\n\n💰 **Compensation:**\n• Salary research\n• Negotiation tactics\n• Evaluating offers\n\n🚀 **Career Development:**\n• Skill building\n• Career transitions\n• Work-life balance\n• Professional growth\n\n📚 **Learning & Growth:**\n• Course recommendations\n• Certifications\n• Industry trends\n\n🤝 **Networking:**\n• Building connections\n• Informational interviews\n• Personal branding\n\nWhat specific topic would you like to explore? Feel free to ask anything!";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: const Color(0xff070C19),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xff3F6CDF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xff3F6CDF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Assistant',
                  style: TextStyle(
                    color: Color(0xff070C19),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xff3F6CDF),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[400]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Typing...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
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
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_messageController.text),
                    child: Container(
                      width: 48,
                      height: 48,
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
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xff3F6CDF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xff3F6CDF),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xff3F6CDF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : const Color(0xff070C19),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xff3F6CDF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
