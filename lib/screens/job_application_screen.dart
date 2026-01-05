import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_buttons.dart';

class JobApplicationScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final List<String> customQuestions;

  const JobApplicationScreen({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    this.customQuestions = const [],
  }) : super(key: key);

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Basic information controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();

  // Custom question answer controllers
  late List<TextEditingController> _customAnswerControllers;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Create controllers for custom questions
    _customAnswerControllers = List.generate(
      widget.customQuestions.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    for (var controller in _customAnswerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Egyptian phone number validation
    final phoneRegex = RegExp(r'^(\+20|0)?1[0125]\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number (e.g., 01012345678)';
    }
    return null;
  }

  String? _validateRegion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Region is required';
    }
    if (value.trim().length < 2) {
      return 'Region must be at least 2 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  String? _validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expected salary is required';
    }
    final salary = int.tryParse(value.trim());
    if (salary == null) {
      return 'Salary must be a number';
    }
    if (salary < 0) {
      return 'Salary cannot be negative';
    }
    return null;
  }

  String? _validateCustomAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Answer is required';
    }
    if (value.trim().length > 1000) {
      return 'Answer cannot exceed 1000 characters';
    }
    return null;
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare custom answers
      final customAnswers = List.generate(
        widget.customQuestions.length,
        (index) => {
          'question': widget.customQuestions[index],
          'answer': _customAnswerControllers[index].text.trim(),
        },
      );

      final applicationData = {
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'region': _regionController.text.trim(),
        'address': _addressController.text.trim(),
        'expectedSalary': int.parse(_salaryController.text.trim()),
        'customAnswers': customAnswers,
      };

      final response = await _apiService.applyToJob(
        widget.jobId,
        applicationData,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Application failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Application',
          style: AppStyles.heading2.copyWith(fontSize: 20),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF5B9FED).withOpacity(0.1),
                        const Color(0xFF7BB8F7).withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.work_outline,
                        color: Color(0xFF5B9FED),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.jobTitle,
                          style: AppStyles.heading2.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Basic Information Section
                Text(
                  'Basic Information',
                  style: AppStyles.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'All fields are required',
                  style: AppStyles.bodySmall.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 16),

                // Full Name
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: _validateName,
                  hint: 'e.g., John Smith',
                ),
                const SizedBox(height: 16),

                // Phone Number
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  validator: _validatePhone,
                  hint: '01012345678',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Region
                _buildTextField(
                  controller: _regionController,
                  label: 'Region',
                  icon: Icons.location_city_outlined,
                  validator: _validateRegion,
                  hint: 'e.g., Cairo',
                ),
                const SizedBox(height: 16),

                // Address
                _buildTextField(
                  controller: _addressController,
                  label: 'Full Address',
                  icon: Icons.home_outlined,
                  validator: _validateAddress,
                  hint: 'e.g., 15 Tahrir Street, Maadi',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Expected Salary
                _buildTextField(
                  controller: _salaryController,
                  label: 'Expected Salary (EGP)',
                  icon: Icons.attach_money,
                  validator: _validateSalary,
                  hint: 'e.g., 5000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                // Custom Questions Section
                if (widget.customQuestions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Additional Questions',
                    style: AppStyles.heading2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please answer all questions',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Custom questions
                  ...List.generate(
                    widget.customQuestions.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${widget.customQuestions[index]}',
                            style: AppStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _customAnswerControllers[index],
                            validator: _validateCustomAnswer,
                            maxLines: 3,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              hintText: 'Type your answer here...',
                              hintStyle: AppStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5B9FED),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Submit Application',
                    onPressed: _submitApplication,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF5B9FED)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B9FED), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
