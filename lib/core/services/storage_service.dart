import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // User Profile
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final raw = _prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  // FinTech Balance Privacy (Masked Eye Toggle)
  bool isBalanceVisible() {
    return _prefs.getBool(AppConstants.balanceVisibilityKey) ?? true;
  }

  Future<void> setBalanceVisible(bool visible) async {
    await _prefs.setBool(AppConstants.balanceVisibilityKey, visible);
  }

  // Dynamic Base URL
  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(AppConstants.baseUrlKey, url);
  }

  String getBaseUrl() {
    return _prefs.getString(AppConstants.baseUrlKey) ?? ApiEndpoints.defaultBaseUrl;
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
