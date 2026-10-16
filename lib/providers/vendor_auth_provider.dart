import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class VendorAuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final StorageService storageService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  VendorAuthProvider({required this.apiClient, required this.storageService});

  Future<void> init() async {
    final user = storageService.getUser();
    if (user != null && user.userType == 'vendor') {
      _currentUser = user;
    } else {
      await storageService.clearAll();
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> login(String loginIdentifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'login': loginIdentifier.trim(),
          'password': password,
        },
      );

      if (res.data['status'] == true && res.data['data'] != null) {
        final data = res.data['data'];
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        // STRICT MATHEMATICAL ROLE INVARIANT:
        // P(Authentication Success | user.userType != 'vendor') = 0.
        // It is mathematically impossible for any non-vendor (customers, riders, logistics,
        // admins, and specifically vendor employees / counter staff) to establish an authenticated
        // session on this terminal. Even with valid credentials, non-vendor tokens are wiped immediately.
        // Counter staff and workers must authenticate exclusively through the Web Staff Portal.
        if (user.userType != 'vendor') {
          await storageService.clearAll();
          if (user.userType == 'vendor_employee') {
            _errorMessage = 'Access Restricted: Branch employees and counter staff are strictly prohibited from this Mobile Terminal. Please sign in via the Web Staff Portal (/counter).';
          } else {
            _errorMessage = 'Access Denied: Only verified Sovereign Merchant Owners can access this terminal.';
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }

        await storageService.saveToken(token);
        await storageService.saveUser(user);
        _currentUser = user;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'Login failed. Please check credentials.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Connection error. Please ensure the newVmarket backend server is running.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await storageService.clearAll();
    _currentUser = null;
    notifyListeners();
  }
}
