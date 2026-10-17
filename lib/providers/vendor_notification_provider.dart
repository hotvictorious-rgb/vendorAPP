import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/services/firebase_notification_service.dart';
import '../models/system_notification_model.dart';

class VendorNotificationProvider with ChangeNotifier {
  final ApiClient _apiClient;

  List<SystemNotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<SystemNotificationModel>? _sub;

  VendorNotificationProvider(this._apiClient) {
    // Listen for live merchant push alerts emitted by FCM service
    _sub = FirebaseNotificationService.instance.onNotificationReceived.listen((notif) {
      _notifications.insert(0, notif);
      _unreadCount++;
      notifyListeners();
    });
  }

  List<SystemNotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.inAppNotifications);
      if (response.statusCode == 200 && response.data['status'] == true) {
        _unreadCount = response.data['unread_count'] as int? ?? 0;
        final rawList = (response.data['notifications'] ?? response.data['data']) as List? ?? [];
        _notifications = rawList
            .map((item) => SystemNotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _errorMessage = 'Unable to refresh merchant alerts.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final old = _notifications[index];
      _notifications[index] = SystemNotificationModel(
        id: old.id,
        userId: old.userId,
        title: old.title,
        body: old.body,
        type: old.type,
        data: old.data,
        actionUrl: old.actionUrl,
        readAt: DateTime.now(),
        createdAt: old.createdAt,
      );
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }

    try {
      await _apiClient.post('${ApiEndpoints.markNotificationRead}/$id');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    _unreadCount = 0;
    _notifications = _notifications.map((n) {
      if (n.isRead) return n;
      return SystemNotificationModel(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        type: n.type,
        data: n.data,
        actionUrl: n.actionUrl,
        readAt: DateTime.now(),
        createdAt: n.createdAt,
      );
    }).toList();
    notifyListeners();

    try {
      await _apiClient.post(ApiEndpoints.markNotificationRead);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}