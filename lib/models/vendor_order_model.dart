class VendorOrderModel {
  final int id;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;
  final String fulfillmentType;
  final String grandTotal;
  final String vendorNet90;
  final String? customerName;
  final String? customerPhone;
  final String? pickupVerificationCode;
  final String? vendorHandoverReadyAt;
  final bool pickupConfirmedByRider;
  final String? riderName;
  final String? riderPhone;
  final String? riderPlateNumber;
  final String? pickupProofImage;
  final String? proofOfDeliveryImage;
  final String? deliveryAttemptPhotoPath;
  final int deliveryAttemptCount;
  final String? deliveryFailureReason;
  final List<DoorstepRejectionPhoto> doorstepRejectionPhotos;
  final List<VendorOrderItem> items;
  final String createdAt;

  VendorOrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
    required this.fulfillmentType,
    required this.grandTotal,
    required this.vendorNet90,
    this.customerName,
    this.customerPhone,
    this.pickupVerificationCode,
    this.vendorHandoverReadyAt,
    required this.pickupConfirmedByRider,
    this.riderName,
    this.riderPhone,
    this.riderPlateNumber,
    this.pickupProofImage,
    this.proofOfDeliveryImage,
    this.deliveryAttemptPhotoPath,
    this.deliveryAttemptCount = 0,
    this.deliveryFailureReason,
    this.doorstepRejectionPhotos = const [],
    required this.items,
    required this.createdAt,
  });

  bool get isReadyForHandover => vendorHandoverReadyAt != null || orderStatus == 'ready_for_pickup';
  bool get hasPhotoAudits =>
      pickupProofImage != null ||
      proofOfDeliveryImage != null ||
      deliveryAttemptPhotoPath != null ||
      doorstepRejectionPhotos.isNotEmpty ||
      items.any((it) => it.defectPhotoPath != null);

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final rider = json['rider'] as Map<String, dynamic>?;
    final riderUser = rider?['user'] as Map<String, dynamic>?;

    final rawItems = json['items'] as List? ?? json['order_items'] as List? ?? [];
    final itemsList = rawItems.map((e) => VendorOrderItem.fromJson(e as Map<String, dynamic>)).toList();

    List<DoorstepRejectionPhoto> rejectionPhotos = [];
    if (json['doorstep_rejection_photos'] is List) {
      rejectionPhotos = (json['doorstep_rejection_photos'] as List)
          .map((e) => DoorstepRejectionPhoto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return VendorOrderModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      fulfillmentType: json['fulfillment_type'] as String? ?? 'doorstep_delivery',
      grandTotal: json['grand_total']?.toString() ?? '0.00',
      vendorNet90: json['vendor_net_90']?.toString() ?? '0.00',
      customerName: customer?['name'] as String? ?? 'Customer',
      customerPhone: customer?['phone'] as String?,
      pickupVerificationCode: json['pickup_verification_code'] as String?,
      vendorHandoverReadyAt: json['vendor_handover_ready_at'] as String?,
      pickupConfirmedByRider: json['pickup_confirmed_by_rider'] as bool? ?? false,
      riderName: riderUser?['name'] as String?,
      riderPhone: riderUser?['phone'] as String?,
      riderPlateNumber: rider?['plate_number'] as String?,
      pickupProofImage: json['pickup_proof_image'] as String?,
      proofOfDeliveryImage: json['proof_of_delivery_image'] as String?,
      deliveryAttemptPhotoPath: json['delivery_attempt_photo_path'] as String?,
      deliveryAttemptCount: json['delivery_attempt_count'] as int? ?? 0,
      deliveryFailureReason: json['delivery_failure_reason'] as String?,
      doorstepRejectionPhotos: rejectionPhotos,
      items: itemsList,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class DoorstepRejectionPhoto {
  final int? orderItemId;
  final String photoPath;
  final String? rejectionCategory;
  final String? rejectionNotes;

  DoorstepRejectionPhoto({
    this.orderItemId,
    required this.photoPath,
    this.rejectionCategory,
    this.rejectionNotes,
  });

  factory DoorstepRejectionPhoto.fromJson(Map<String, dynamic> json) {
    return DoorstepRejectionPhoto(
      orderItemId: json['order_item_id'] as int?,
      photoPath: json['photo_path'] as String? ?? json['photo'] as String? ?? '',
      rejectionCategory: json['rejection_category'] as String?,
      rejectionNotes: json['rejection_notes'] as String?,
    );
  }
}

class VendorOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String unitPrice;
  final int quantity;
  final int rejectedQuantity;
  final String? thumbnail;
  final String? defectPhotoPath;
  final String? rejectionCategory;
  final String? rejectionNotes;
  final String? itemDeliveryStatus;

  VendorOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.rejectedQuantity = 0,
    this.thumbnail,
    this.defectPhotoPath,
    this.rejectionCategory,
    this.rejectionNotes,
    this.itemDeliveryStatus,
  });

  bool get isRejected => rejectedQuantity > 0 || itemDeliveryStatus == 'rejected_in_transit' || itemDeliveryStatus == 'partially_accepted';

  factory VendorOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return VendorOrderItem(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: product?['name'] as String? ?? json['product_name'] as String? ?? 'Item',
      unitPrice: json['unit_price']?.toString() ?? product?['unit_price']?.toString() ?? '0.00',
      quantity: json['quantity'] as int? ?? 1,
      rejectedQuantity: json['rejected_quantity'] as int? ?? 0,
      thumbnail: product?['thumbnail'] as String? ?? product?['image_path'] as String?,
      defectPhotoPath: json['defect_photo_path'] as String?,
      rejectionCategory: json['rejection_category'] as String?,
      rejectionNotes: json['rejection_notes'] as String?,
      itemDeliveryStatus: json['item_delivery_status'] as String?,
    );
  }
}
