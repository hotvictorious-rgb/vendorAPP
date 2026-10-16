import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/vendor_product_model.dart';

class VendorProductsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<VendorProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VendorProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VendorProductsProvider({required this.apiClient});

  Future<void> fetchProducts({String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;

      final res = await apiClient.get(ApiEndpoints.products, queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _products = list.map((e) => VendorProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load catalog products.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> refreshFreshness(int productId) async {
    try {
      final res = await apiClient.post('${ApiEndpoints.refreshFreshness}$productId/freshness');
      if (res.data['status'] == true) {
        await fetchProducts();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> toggleStock(int productId, {int? quantity, bool? isInStock}) async {
    try {
      final Map<String, dynamic> body = {};
      if (quantity != null) body['quantity'] = quantity;
      if (isInStock != null) body['is_in_stock'] = isInStock;

      final res = await apiClient.post('${ApiEndpoints.toggleStock}$productId/toggle-stock', data: body);
      if (res.data['status'] == true) {
        await fetchProducts();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> createProduct({
    required String name,
    required double price,
    required int quantity,
    required int categoryId,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.products,
        data: {
          'name': name.trim(),
          'unit_price': price,
          'inventory_quantity': quantity,
          'category_id': categoryId,
          'description': description?.trim(),
        },
      );

      if (res.data['status'] == true) {
        await fetchProducts();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to publish product.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
