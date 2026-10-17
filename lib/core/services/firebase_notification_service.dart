import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import 'storage_service.dart';
import '../../models/system_notification_model.dart';

/// Enterprise Firebase Cloud Messaging & Merchant Notification Service
/// Handles device token registry, background/foreground merchant alerts,
/// and live event streams for the Sovereign Merchant Terminal.
class FirebaseNotificationService {
  static final FirebaseNotificationService instance = FirebaseNotificationService._internal();

  FirebaseNotificationService._internal();

  final _notificationStreamController = StreamController<SystemNotificationModel>.broadcast();
  Stream<SystemNotificationModel> get onNotificationReceived => _notificationStreamController.stream;

  bool _isRegistered = false;
  String? _cachedDeviceToken;

  bool get isRegistered => _isRegistered;
  String? get cachedDeviceToken => _cachedDeviceToken;

  /// Generate or retrieve persistent hardware/FCM terminal identifier
  Future<String> getOrGenerateDeviceToken(StorageService storage) async {
    if (_cachedDeviceToken != null && _cachedDeviceToken!.isNotEmpty) {
      return _cachedDeviceToken!;
    }

    final stored = storage.getDeviceToken();
    if (stored != null && stored.isNotEmpty) {
      _cachedDeviceToken = stored;
      return stored;
    }

    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    final token = 'fcm_vendor_${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

    await storage.setDeviceToken(token);
    _cachedDeviceToken = token;
    return token;
  }

  /// Register current merchant device token with Victorious Backend Notification Matrix
  Future<bool> registerWithBackend({
    required ApiClient apiClient,
    required StorageService storage,
    String? deviceName,
  }) async {
    try {
      final token = await getOrGenerateDeviceToken(storage);
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

      final response = await apiClient.post(
        ApiEndpoints.registerDeviceToken,
        data: {
          'device_token': token,
          'device_type': platform,
          'app_type': 'vendor',
          'device_name': deviceName ?? 'Victorious Merchant Terminal (v1.0.0)',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isRegistered = true;
        debugPrint('[FCM Merchant Service] Device token successfully registered with backend: $token');
        return true;
      }
    } catch (e) {
      debugPrint('[FCM Merchant Service] Device token registration skipped or failed: $e');
    }
    return false;
  }

  /// Revoke merchant device token on logout
  Future<bool> unregisterWithBackend({
    required ApiClient apiClient,
    required StorageService storage,
  }) async {
    try {
      final token = storage.getDeviceToken() ?? _cachedDeviceToken;
      if (token == null || token.isEmpty) return true;

      final response = await apiClient.delete(
        ApiEndpoints.revokeDeviceToken,
        data: {
          'device_token': token,
        },
      );

      if (response.statusCode == 200) {
        _isRegistered = false;
        await storage.clearDeviceToken();
        _cachedDeviceToken = null;
        debugPrint('[FCM Merchant Service] Device token revoked successfully from matrix.');
        return true;
      }
    } catch (e) {
      debugPrint('[FCM Merchant Service] Device token revocation warning: $e');
    }
    return false;
  }

  /// Broadcast incoming push/dispatch alert to terminal UI listeners
  void handleIncomingMessage(Map<String, dynamic> raw) {
    try {
      final notification = SystemNotificationModel.fromJson(raw);
      _notificationStreamController.add(notification);
    } catch (e) {
      debugPrint('[FCM Merchant Service] Failed to parse incoming notification: $e');
    }
  }

  void dispose() {
    _notificationStreamController.close();
  }
}