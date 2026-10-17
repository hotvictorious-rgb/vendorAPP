import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

class SystemNotificationModel {
  final String id;
  final int? userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final DateTime? readAt;
  final DateTime? createdAt;

  SystemNotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.actionUrl,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  factory SystemNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return SystemNotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      title: json['title']?.toString() ?? 'Merchant Alert',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      actionUrl: json['action_url']?.toString(),
      readAt: parseDate(json['read_at']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  String get timeAgo {
    if (createdAt == null) return 'Recent';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, h:mm a').format(createdAt!);
  }

  IconData get iconData {
    final t = type.toLowerCase();
    if (t.contains('order') || t.contains('purchase')) {
      return Icons.shopping_bag_outlined;
    }
    if (t.contains('pickup') || t.contains('handover') || t.contains('ready')) {
      return Icons.inventory_2_outlined;
    }
    if (t.contains('payout') || t.contains('settlement') || t.contains('wallet')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (t.contains('return') || t.contains('counter')) {
      return Icons.assignment_return_outlined;
    }
    if (t.contains('dispute') || t.contains('arbitration')) {
      return Icons.gavel_outlined;
    }
    if (t.contains('fail') || t.contains('warning') || t.contains('alert')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.notifications_active_outlined;
  }

  Color get accentColor {
    final t = type.toLowerCase();
    if (t.contains('fail') || t.contains('rejected') || t.contains('warning') || t.contains('dispute')) {
      return AppColors.error;
    }
    if (t.contains('payout') || t.contains('settlement') || t.contains('success')) {
      return AppColors.success;
    }
    if (t.contains('pickup') || t.contains('handover') || t.contains('ready') || t.contains('return')) {
      return AppColors.goldAccent;
    }
    return AppColors.primaryPurple;
  }
}