class VendorProductModel {
  final int id;
  final String name;
  final String? slug;
  final String unitPrice;
  final String? slashPrice;
  final int? discountPercent;
  final int inventoryQuantity;
  final bool isInStock;
  final int? categoryId;
  final String categoryName;
  final String shopName;
  final String? description;
  final String? imagePath;
  final List<String> images;
  final String condition;
  final String conditionLabel;
  final String packageTier;
  final String packageTierLabel;
  final String warrantyType;
  final String warrantyLabel;
  final String? videoUrl;
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
    this.slashPrice,
    this.discountPercent,
    required this.inventoryQuantity,
    required this.isInStock,
    this.categoryId,
    required this.categoryName,
    required this.shopName,
    this.description,
    this.imagePath,
    this.images = const [],
    this.condition = 'brand_new',
    this.conditionLabel = 'Brand New (Sealed Pack)',
    this.packageTier = 'bike',
    this.packageTierLabel = 'Bike Dispatch (Standard Parcel)',
    this.warrantyType = 'in_store_testing',
    this.warrantyLabel = 'Doorstep / In-Store Testing on Arrival',
    this.videoUrl,
    required this.isFresh,
    this.listingConfirmedAt,
    this.freshnessExpiresAt,
    required this.daysRemaining,
    required this.isApproved,
    required this.isFlagship,
  });

  bool get isUkUsed => condition == 'uk_used';
  bool get isKekeCargo => packageTier == 'keke' || packageTier == 'bulky';

  factory VendorProductModel.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'] as String? ?? 'brand_new';
    final packageTier = json['package_tier'] as String? ?? 'bike';
    final warrantyType = json['warranty_type'] as String? ?? 'in_store_testing';
    final rawImages = json['images'] as List? ?? [];
    final imageList = rawImages.map((e) => e.toString()).toList();

    return VendorProductModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Product',
      slug: json['slug'] as String?,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      slashPrice: json['slash_price']?.toString(),
      discountPercent: json['discount_percent'] as int?,
      inventoryQuantity: json['inventory_quantity'] as int? ?? 0,
      isInStock: json['is_in_stock'] as bool? ??
          (json['inventory_quantity'] as int? ?? 0) > 0,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String? ??
          json['category']?['name'] as String? ??
          'General',
      shopName: json['shop_name'] as String? ??
          json['shop']?['name'] as String? ??
          'Shop',
      description: json['description'] as String?,
      imagePath: json['thumbnail'] as String? ?? json['image_path'] as String?,
      images: imageList,
      condition: condition,
      conditionLabel: json['condition_label'] as String? ??
          (condition == 'uk_used'
              ? 'UK Used (Clean Grade A)'
              : 'Brand New (Sealed Pack)'),
      packageTier: packageTier,
      packageTierLabel: json['package_tier_label'] as String? ??
          (packageTier == 'keke'
              ? 'Keke Cargo (Heavy / Bulky Surcharge)'
              : 'Bike Dispatch (Standard Parcel)'),
      warrantyType: warrantyType,
      warrantyLabel: json['warranty_label'] as String? ??
          'Doorstep / In-Store Testing on Arrival',
      videoUrl: json['video_url'] as String?,
      isFresh: json['is_fresh'] as bool? ?? true,
      listingConfirmedAt: json['listing_confirmed_at'] as String?,
      freshnessExpiresAt: json['freshness_expires_at'] as String?,
      daysRemaining: json['days_remaining'] as int? ?? 7,
      isApproved: json['is_approved'] as bool? ?? true,
      isFlagship: json['is_flagship'] as bool? ?? false,
    );
  }
}
