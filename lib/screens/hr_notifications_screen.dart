import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/hr_notification.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';

class HRNotificationsScreen extends StatefulWidget {
  const HRNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<HRNotificationsScreen> createState() => _HRNotificationsScreenState();
}

class _HRNotificationsScreenState extends State<HRNotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<HRNotification> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getHRNotifications();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _notifications = (response['data'] as List)
              .map((n) => HRNotification.fromJson(n))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildError()
                    : _buildNotificationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Text('Notifications', style: AppStyles.heading1),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load notifications', style: AppStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No notifications', style: AppStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(HRNotification notification) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notification.type,
                ).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppStyles.heading3.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification.createdAt),
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.person_add_outlined;
      case 'job':
        return Icons.work_outline;
      case 'message':
        return Icons.message_outlined;
      case 'alert':
        return Icons.warning_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'application':
        return AppColors.primaryGreen;
      case 'job':
        return AppColors.primaryBlue;
      case 'message':
        return AppColors.success;
      case 'alert':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
