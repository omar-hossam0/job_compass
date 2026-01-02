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
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 3) {
      return 'الاسم لازم يكون 3 حروف على الأقل';
    }
    if (value.trim().length > 100) {
      return 'الاسم لا يمكن أن يتجاوز 100 حرف';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم التليفون مطلوب';
    }
    // Egyptian phone number validation
    final phoneRegex = RegExp(r'^(\+20|0)?1[0125]\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم تليفون مصري غير صحيح (مثال: 01012345678)';
    }
    return null;
  }

  String? _validateRegion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'المنطقة مطلوبة';
    }
    if (value.trim().length < 2) {
      return 'المنطقة لازم تكون حرفين على الأقل';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }
    if (value.trim().length < 10) {
      return 'العنوان لازم يكون 10 حروف على الأقل';
    }
    return null;
  }

  String? _validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'السالري المتوقع مطلوب';
    }
    final salary = int.tryParse(value.trim());
    if (salary == null) {
      return 'السالري لازم يكون رقم';
    }
    if (salary < 0) {
      return 'السالري لا يمكن أن يكون سالب';
    }
    return null;
  }

  String? _validateCustomAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الإجابة مطلوبة';
    }
    if (value.trim().length > 1000) {
      return 'الإجابة لا يمكن أن تتجاوز 1000 حرف';
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
              content: Text('تم التقديم بنجاح! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'فشل التقديم'),
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
            content: Text('خطأ: ${e.toString()}'),
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
          'التقديم على الوظيفة',
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
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.work_outline,
                        color: AppColors.primaryTeal,
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
                  'المعلومات الأساسية',
                  style: AppStyles.heading2.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'جميع الحقول مطلوبة',
                  style: AppStyles.bodySmall.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 16),

                // Full Name
                _buildTextField(
                  controller: _fullNameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline,
                  validator: _validateName,
                  hint: 'مثال: أحمد محمد علي',
                ),
                const SizedBox(height: 16),

                // Phone Number
                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم التليفون',
                  icon: Icons.phone_outlined,
                  validator: _validatePhone,
                  hint: '01012345678',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Region
                _buildTextField(
                  controller: _regionController,
                  label: 'المنطقة',
                  icon: Icons.location_city_outlined,
                  validator: _validateRegion,
                  hint: 'مثال: القاهرة',
                ),
                const SizedBox(height: 16),

                // Address
                _buildTextField(
                  controller: _addressController,
                  label: 'العنوان بالتفصيل',
                  icon: Icons.home_outlined,
                  validator: _validateAddress,
                  hint: 'مثال: 15 شارع التحرير، المعادي',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Expected Salary
                _buildTextField(
                  controller: _salaryController,
                  label: 'السالري المتوقع (جنيه مصري)',
                  icon: Icons.attach_money,
                  validator: _validateSalary,
                  hint: 'مثال: 5000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                // Custom Questions Section
                if (widget.customQuestions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'أسئلة إضافية',
                    style: AppStyles.heading2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يرجى الإجابة على جميع الأسئلة',
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
                              hintText: 'اكتب إجابتك هنا...',
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
                                  color: AppColors.primaryTeal,
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
                    text: 'تقديم الطلب',
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
            prefixIcon: Icon(icon, color: AppColors.primaryTeal),
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
              borderSide: const BorderSide(
                color: AppColors.primaryTeal,
                width: 2,
              ),
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
