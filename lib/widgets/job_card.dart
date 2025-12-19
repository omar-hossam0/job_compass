import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/student.dart';
import 'glass_card.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  
  const JobCard({
    Key? key,
    required this.job,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Company logo + Title
          Row(
            children: [
              // Company Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: job.companyLogo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          job.companyLogo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.business,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: AppColors.primaryGreen,
                      ),
              ),
              const SizedBox(width: 12),
              // Title and Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: AppStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: AppStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Bookmark icon
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Employment types
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.employmentType.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  type,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Salary and Match Score
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salary yearly',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${(job.salary / 1000).toStringAsFixed(0)}k${job.salaryPeriod}',
                      style: AppStyles.heading3.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.2),
                      AppColors.primaryTeal.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.show_chart,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job.matchScore.toInt()}% Match',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Applicants count
          Row(
            children: [
              // Applicant avatars (placeholder)
              SizedBox(
                width: 80,
                height: 30,
                child: Stack(
                  children: List.generate(
                    3,
                    (index) => Positioned(
                      left: index * 20.0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${job.applicantsCount}+ Apply',
                style: AppStyles.bodySmall,
              ),
              const Spacer(),
              // Arrow button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
