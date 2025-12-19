import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/interview.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';

class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({Key? key}) : super(key: key);

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = false;
  InterviewSession? _session;
  int _currentQuestionIndex = 0;
  String? _error;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.startInterviewSession({
        'jobTitle': 'General Interview',
      });
      
      setState(() {
        _session = InterviewSession.fromJson(response);
        _currentQuestionIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Simulate AI response
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _currentQuestionIndex++;
        _answerController.clear();
        _isLoading = false;
      });

      if (_currentQuestionIndex >= _session!.questions.length) {
        _showFeedback();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFeedbackSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: LoadingOverlay(
          isLoading: _isLoading && _session == null,
          child: SafeArea(
            child: _session == null
                ? _buildWelcome()
                : _currentQuestionIndex < _session!.questions.length
                    ? _buildInterview()
                    : _buildComplete(),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButtonCircular(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.white.withOpacity(0.3),
                iconColor: AppColors.textPrimary,
              ),
              const SizedBox(width: 16),
              Text('Interview Prep', style: AppStyles.heading2),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryGreen, AppColors.primaryTeal]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 80),
                  ),
                  const SizedBox(height: 32),
                  Text('AI Interview Simulator', style: AppStyles.heading1.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Practice with AI-powered interview questions and get real-time feedback',
                      style: AppStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.check_circle, 'Common interview questions'),
                        const SizedBox(height: 12),
                        _buildFeatureRow(Icons.feedback, 'AI-powered feedback'),
                        const SizedBox(height: 12),
                        _buildFeatureRow(Icons.analytics, 'Strengths & weaknesses'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Start Interview',
                    onPressed: _startSession,
                    icon: Icons.play_arrow,
                    width: 250,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.success, size: 20),
        const SizedBox(width: 12),
        Text(text, style: AppStyles.bodyMedium),
      ],
    );
  }

  Widget _buildInterview() {
    final question = _session!.questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButtonCircular(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.white.withOpacity(0.3),
                iconColor: AppColors.textPrimary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _session!.questions.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text('${_currentQuestionIndex + 1}/${_session!.questions.length}', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.question_answer, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('Question ${_currentQuestionIndex + 1}', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(question.question, style: AppStyles.heading3.copyWith(height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Your Answer', style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _answerController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Type your answer here...',
                        border: InputBorder.none,
                        hintStyle: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      style: AppStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: _currentQuestionIndex < _session!.questions.length - 1 ? 'Next Question' : 'Finish Interview',
            onPressed: _submitAnswer,
            isLoading: _isLoading,
            icon: Icons.arrow_forward,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildComplete() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.7)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 80),
            ),
            const SizedBox(height: 32),
            Text('Interview Complete!', style: AppStyles.heading1),
            const SizedBox(height: 16),
            Text('Great job completing the practice session', style: AppStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            PrimaryButton(
              text: 'View Feedback',
              onPressed: _showFeedback,
              icon: Icons.analytics,
              width: 250,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: 'Start New Session',
              onPressed: _startSession,
              icon: Icons.refresh,
              width: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSheet() {
    final feedback = InterviewFeedback(
      strengths: ['Clear communication', 'Good examples', 'Confident delivery'],
      weaknesses: ['Could provide more details', 'Practice technical terms'],
      overallScore: 85,
      summary: 'You demonstrated strong communication skills and provided relevant examples.',
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interview Feedback', style: AppStyles.heading2),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text('Overall Score:', style: AppStyles.bodyMedium),
                const Spacer(),
                Text('${feedback.overallScore}%', style: AppStyles.heading1.copyWith(color: AppColors.success)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: AppStyles.heading3),
                  const SizedBox(height: 12),
                  Text(feedback.summary, style: AppStyles.bodyMedium),
                  const SizedBox(height: 24),
                  Text('Strengths', style: AppStyles.heading3),
                  const SizedBox(height: 12),
                  ...feedback.strengths.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s, style: AppStyles.bodyMedium)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  Text('Areas to Improve', style: AppStyles.heading3),
                  const SizedBox(height: 12),
                  ...feedback.weaknesses.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(w, style: AppStyles.bodyMedium)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Done',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
