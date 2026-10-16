class VendorProductModel {
  final int id;
  final String name;
  final String? slug;
  final String unitPrice;
  final int inventoryQuantity;
  final bool isInStock;
  final String categoryName;
  final String shopName;
  final String? imagePath;
  final bool isFresh;
  final String? listingConfirmedAt;
  final String? freshnessExpiresAt;
  final int daysRemaining;
  final bool isApproved;
  final bool isFlagship;

  VendorProductModel({
    required this.id,
    required this.name,
    this.slug,
    required this.unitPrice,
    required this.inventoryQuantity,
    required this.isInStock,
    required this.categoryName,
    required this.shopName,
    this.imagePath,
    required this.isFresh,
    this.listingConfirmedAt,
    this.freshnessExpiresAt,
    required this.daysRemaining,
    required this.isApproved,
    required this.isFlagship,
  });

  factory VendorProductModel.fromJson(Map<String, dynamic> json) {
    return VendorProductModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Product',
      slug: json['slug'] as String?,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      inventoryQuantity: json['inventory_quantity'] as int? ?? 0,
      isInStock: json['is_in_stock'] as bool? ?? (json['inventory_quantity'] as int? ?? 0) > 0,
      categoryName: json['category_name'] as String? ?? 'General',
      shopName: json['shop_name'] as String? ?? 'Shop',
      imagePath: json['image_path'] as String?,
      isFresh: json['is_fresh'] as bool? ?? true,
      listingConfirmedAt: json['listing_confirmed_at'] as String?,
      freshnessExpiresAt: json['freshness_expires_at'] as String?,
      daysRemaining: json['days_remaining'] as int? ?? 7,
      isApproved: json['is_approved'] as bool? ?? true,
      isFlagship: json['is_flagship'] as bool? ?? false,
    );
  }
}
