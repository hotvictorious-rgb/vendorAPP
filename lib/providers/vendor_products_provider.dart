import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/vendor_product_model.dart';

class CategoryItem {
  final int id;
  final String name;
  final String? icon;

  CategoryItem({required this.id, required this.name, this.icon});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as int? ?? 1,
      name: json['name'] as String? ?? 'General',
      icon: json['icon'] as String?,
    );
  }
}

class VendorProductsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<VendorProductModel> _products = [];
  List<CategoryItem> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VendorProductModel> get products => _products;
  List<CategoryItem> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VendorProductsProvider({required this.apiClient});

  Future<void> fetchCategories() async {
    try {
      final res = await apiClient.get(ApiEndpoints.categories);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _categories = list.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchProducts({String? search, String? condition, String? packageTier}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (condition != null && condition.isNotEmpty) params['condition'] = condition;
      if (packageTier != null && packageTier.isNotEmpty) params['package_tier'] = packageTier;

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
    double? slashPrice,
    required int quantity,
    required int categoryId,
    String condition = 'brand_new',
    String packageTier = 'bike',
    String warrantyType = 'in_store_testing',
    String? description,
    String? videoUrl,
    String? imageUrl,
    File? imageFile,
    List<File>? galleryFiles,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        'name': name.trim(),
        'unit_price': price,
        'inventory_quantity': quantity,
        'category_id': categoryId,
        'condition': condition,
        'package_tier': packageTier,
        'warranty_type': warrantyType,
      };

      if (slashPrice != null && slashPrice > price) {
        body['slash_price'] = slashPrice;
      }
      if (description != null && description.trim().isNotEmpty) {
        body['description'] = description.trim();
      }
      if (videoUrl != null && videoUrl.trim().isNotEmpty) {
        body['video_url'] = videoUrl.trim();
      }
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        body['image_url'] = imageUrl.trim();
      }

      dynamic payload = body;
      if (imageFile != null || (galleryFiles != null && galleryFiles.isNotEmpty)) {
        final formMap = Map<String, dynamic>.from(body);
        if (imageFile != null) {
          formMap['image'] = await MultipartFile.fromFile(
            imageFile.path,
            filename: 'prod_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }
        if (galleryFiles != null && galleryFiles.isNotEmpty) {
          for (int i = 0; i < galleryFiles.length; i++) {
            formMap['images[$i]'] = await MultipartFile.fromFile(
              galleryFiles[i].path,
              filename: 'gallery_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          }
        }
        payload = FormData.fromMap(formMap);
      }

      final res = await apiClient.post(ApiEndpoints.products, data: payload);

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

  Future<bool> updateProduct({
    required int productId,
    required String name,
    required double price,
    double? slashPrice,
    required int quantity,
    required int categoryId,
    String condition = 'brand_new',
    String packageTier = 'bike',
    String warrantyType = 'in_store_testing',
    String? description,
    String? videoUrl,
    String? imageUrl,
    File? imageFile,
    List<File>? galleryFiles,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        'name': name.trim(),
        'unit_price': price,
        'inventory_quantity': quantity,
        'category_id': categoryId,
        'condition': condition,
        'package_tier': packageTier,
        'warranty_type': warrantyType,
      };

      if (slashPrice != null && slashPrice > 0) {
        body['slash_price'] = slashPrice;
      }
      if (description != null && description.trim().isNotEmpty) {
        body['description'] = description.trim();
      }
      if (videoUrl != null && videoUrl.trim().isNotEmpty) {
        body['video_url'] = videoUrl.trim();
      }
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        body['image_url'] = imageUrl.trim();
      }

      dynamic payload = body;
      if (imageFile != null || (galleryFiles != null && galleryFiles.isNotEmpty)) {
        final formMap = Map<String, dynamic>.from(body);
        if (imageFile != null) {
          formMap['image'] = await MultipartFile.fromFile(
            imageFile.path,
            filename: 'prod_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }
        if (galleryFiles != null && galleryFiles.isNotEmpty) {
          for (int i = 0; i < galleryFiles.length; i++) {
            formMap['images[$i]'] = await MultipartFile.fromFile(
              galleryFiles[i].path,
              filename: 'gallery_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          }
        }
        payload = FormData.fromMap(formMap);
      }

      final res = await apiClient.post('${ApiEndpoints.updateProduct}$productId', data: payload);

      if (res.data['status'] == true) {
        await fetchProducts();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to update product.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
