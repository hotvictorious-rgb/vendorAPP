import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/vendor_reservation_model.dart';

class VendorReservationsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<VendorReservationModel> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VendorReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VendorReservationsProvider({required this.apiClient});

  Future<void> fetchReservations({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (status != null) params['status'] = status;

      final res = await apiClient.get(ApiEndpoints.pickupReservations, queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _reservations = list.map((e) => VendorReservationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load inspection reservations.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> verifyInspection(String reservationCode) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.verifyInspection,
        data: {
          'reservation_code': reservationCode.trim().toUpperCase(),
        },
      );

      if (res.data['status'] == true) {
        await fetchReservations();
        return {'success': true, 'message': res.data['message'] ?? 'Physical inspection verified and signed off!'};
      } else {
        return {'success': false, 'message': res.data['message'] ?? 'Inspection verification failed.'};
      }
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Inspection signoff failed. Please check network.'};
    }
  }
}
