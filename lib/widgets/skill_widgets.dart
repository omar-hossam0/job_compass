import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  
  const SkillChip({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: backgroundColor ?? AppColors.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: textColor ?? AppColors.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SkillLevelIndicator extends StatelessWidget {
  final String level; // Beginner, Intermediate, Advanced
  
  const SkillLevelIndicator({
    Key? key,
    required this.level,
  }) : super(key: key);

  Color _getLevelColor() {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.info;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getLevelColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: AppStyles.bodySmall.copyWith(
          color: _getLevelColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProficiencyBar extends StatelessWidget {
  final double value; // 0-100
  final Color? color;
  final double height;
  
  const ProficiencyBar({
    Key? key,
    required this.value,
    this.color,
    this.height = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value / 100,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color ?? AppColors.primaryGreen,
                (color ?? AppColors.primaryGreen).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
