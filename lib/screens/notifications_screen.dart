import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_buttons.dart';
import 'job_applicants_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
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

      if (response['success'] == true) {
        final notifList = (response['data'] as List)
            .map((n) => NotificationModel.fromJson(n))
            .toList();

        setState(() {
          _notifications = notifList;
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
        child: LoadingOverlay(
          isLoading: _isLoading && _notifications.isEmpty,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _error != null
                      ? _buildError()
                      : _notifications.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          color: AppColors.primaryGreen,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) =>
                                _buildNotificationCard(_notifications[index]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load notifications', style: AppStyles.heading3),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadNotifications,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text('No Notifications', style: AppStyles.heading2),
            const SizedBox(height: 12),
            Text(
              'You\'re all caught up!',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButtonCircular(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white.withOpacity(0.3),
            iconColor: AppColors.textPrimary,
          ),
          const SizedBox(width: 16),
          Text('Notifications', style: AppStyles.heading2),
          const Spacer(),
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    // Mark as read logic here
                  }
                });
              },
              child: Text(
                'Mark all read',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    print('📝 Building notification card: ${notification.title}');
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        print('👆 GlassCard tapped!');
        _handleNotificationTap(notification);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppStyles.bodyMedium.copyWith(
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
                const SizedBox(height: 4),
                Text(notification.message, style: AppStyles.bodySmall),
                const SizedBox(height: 8),
                Text(
                  _formatTime(notification.createdAt),
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    print('🔔 Notification tapped!');
    print('Type: ${notification.type}');
    print('Metadata: ${notification.metadata}');

    // Handle notification tap based on type and metadata
    if (notification.type == 'application') {
      if (notification.metadata != null && notification.metadata!.isNotEmpty) {
        final jobId = notification.metadata!['jobId'];
        final jobTitle = notification.metadata!['jobTitle'] ?? 'الوظيفة';

        print('JobId: $jobId');
        print('JobTitle: $jobTitle');

        if (jobId != null) {
          print('✅ Navigating to JobApplicantsScreen...');
          // Navigate to job applicants screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobApplicantsScreen(
                jobId: jobId.toString(),
                jobTitle: jobTitle.toString(),
              ),
            ),
          );

          // Mark notification as read
          _markNotificationAsRead(notification.id);
        } else {
          print('❌ JobId is null!');
          _showErrorSnackBar('معلومات الإشعار غير كاملة');
        }
      } else {
        print('❌ Metadata is null or empty!');
        _showErrorSnackBar('معلومات الإشعار غير متوفرة');
      }
    } else {
      print('ℹ️ Notification type is not "application": ${notification.type}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      // Call API to mark as read
      await _apiService.markNotificationAsRead(notificationId);

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Reload notifications to get updated state
          _loadNotifications();
        }
      });
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.person_add;
      case 'job_match':
        return Icons.work;
      case 'learning_update':
        return Icons.school;
      case 'interview_reminder':
      case 'interview':
        return Icons.event;
      case 'system':
        return Icons.info;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'application':
        return AppColors.info;
      case 'job_match':
        return AppColors.success;
      case 'learning_update':
        return AppColors.info;
      case 'interview_reminder':
      case 'interview':
        return AppColors.warning;
      case 'system':
        return AppColors.textSecondary;
      case 'message':
        return AppColors.primaryGreen;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
