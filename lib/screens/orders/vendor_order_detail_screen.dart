import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/vendor_orders_provider.dart';
import '../../widgets/handover_otp_dialog.dart';
import '../../widgets/photo_audit_viewer_dialog.dart';

class VendorOrderDetailScreen extends StatelessWidget {
  final VendorOrderModel order;

  const VendorOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorOrdersProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Order #${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Halted Warning Banner
            if (order.isHalted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_outlined, color: Color(0xFFDC2626), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TRANSIT HALTED BY FLEET LOGISTICS',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF991B1B)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            order.deliveryHaltedReason ?? 'Delivery temporarily halted due to incident or route curfew.',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Status & Financial Snapshot Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Merchandise Value:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(CurrencyFormatter.format(order.grandTotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Guaranteed Merchant Net (90%):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.success)),
                      Text(CurrencyFormatter.format(order.vendorNet90), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CUSTOMER DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(order.customerName ?? 'Verified Customer', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  if (order.customerPhone != null) ...[
                    const SizedBox(height: 2),
                    Text(order.customerPhone!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      order.fulfillmentType == 'doorstep_delivery' ? '🚀 Directional Doorstep Delivery' : '🏪 In-Shop Customer Pickup',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Dispatch Courier Card
            if (order.riderName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ASSIGNED DISPATCH COURIER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.two_wheeler, color: Color(0xFF15803D)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.riderName!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              if (order.riderPhone != null)
                                Text(order.riderPhone!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (order.riderPlateNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBackground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              order.riderPlateNumber!,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 📸 Immutable Multi-Party Photo Audit Trail
            if (order.hasPhotoAudits) ...[
              _buildPhotoAuditSection(context),
              const SizedBox(height: 16),
            ],

            // Itemized Products
            const Text('PURCHASED LINE ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = order.items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.thumbnail != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: ApiEndpoints.resolveImageUrl(item.thumbnail),
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple),
                                      ),
                                    )
                                  : const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty: ${item.quantity} • ${CurrencyFormatter.format(item.unitPrice)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (item.isRejected) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'REJECTED (${item.rejectedQuantity})',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Line-item defect note and photo if rejected
                        if (item.defectPhotoPath != null || item.rejectionNotes != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFECDD3)),
                            ),
                            child: Row(
                              children: [
                                if (item.defectPhotoPath != null) ...[
                                  InkWell(
                                    onTap: () {
                                      PhotoAuditViewerDialog.show(
                                        context,
                                        title: '${item.productName} Defect',
                                        subtitle: item.rejectionCategory ?? 'Doorstep rejection photo',
                                        imagePath: item.defectPhotoPath!,
                                        badgeLabel: 'Item Defect Snap',
                                        badgeColor: Colors.red,
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl: ApiEndpoints.resolveImageUrl(item.defectPhotoPath),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 24, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (item.rejectionCategory != null)
                                        Text(
                                          item.rejectionCategory!.replaceAll('_', ' ').toUpperCase(),
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFBE123C)),
                                        ),
                                      if (item.rejectionNotes != null)
                                        Text(
                                          item.rejectionNotes!,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF881337)),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Handover Verification Action
            if (order.orderStatus != 'delivered') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.isReadyForHandover ? const Color(0xFF0D9488) : AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(order.isReadyForHandover ? Icons.key : Icons.check_circle_outline, size: 18),
                  label: Text(
                    order.isReadyForHandover ? 'Verify Courier PIN & Release' : 'Mark Ready for Courier Pickup',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                  ),
                  onPressed: () {
                    if (order.isReadyForHandover) {
                      HandoverOtpDialog.show(
                        context,
                        orderId: order.id,
                        orderNumber: order.orderNumber,
                        onVerify: (otp) => provider.verifyHandoverOtp(order.id, otp),
                      );
                    } else {
                      provider.markReadyForHandover(order.id);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAuditSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'IMMUTABLE PHOTO AUDIT TRAIL',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'VERIFIED SNAPS',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Leg 0: Courier Pickup Snap
          if (order.pickupProofImage != null)
            _buildAuditRow(
              context,
              title: 'Courier Counter Pickup Snap',
              subtitle: 'Package released to rider in good condition',
              imagePath: order.pickupProofImage!,
              badge: 'Leg 0: Counter Handover',
              badgeColor: const Color(0xFF0D9488),
            ),

          // Leg 1: Doorstep Delivery Proof Snap
          if (order.proofOfDeliveryImage != null)
            _buildAuditRow(
              context,
              title: 'Doorstep Delivery Proof Snap',
              subtitle: 'Customer received parcel and verified delivery PIN',
              imagePath: order.proofOfDeliveryImage!,
              badge: 'Leg 1: Delivered to Customer',
              badgeColor: AppColors.success,
            ),

          // Leg 1-Attempt: Courier Attempt Failure Snap
          if (order.deliveryAttemptPhotoPath != null)
            _buildAuditRow(
              context,
              title: 'Doorstep Attempt Failure Snap',
              subtitle: order.deliveryFailureReason ?? 'Locked gate or recipient unreachable',
              imagePath: order.deliveryAttemptPhotoPath!,
              badge: '⚠️ Attempt #${order.deliveryAttemptCount}',
              badgeColor: const Color(0xFFD97706),
            ),

          // Line-Item Doorstep Defects
          if (order.doorstepRejectionPhotos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Doorstep Defect Rejection Evidence (${order.doorstepRejectionPhotos.length}):',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: order.doorstepRejectionPhotos.map((photo) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        PhotoAuditViewerDialog.show(
                          context,
                          title: 'Doorstep Defect Snap',
                          subtitle: photo.rejectionCategory ?? 'Customer doorstep inspection rejection',
                          imagePath: photo.photoPath,
                          badgeLabel: 'Customer Rejection Evidence',
                          badgeColor: Colors.red,
                        );
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: ApiEndpoints.resolveImageUrl(photo.photoPath),
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 80,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 20, color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            photo.rejectionCategory ?? 'Defect',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required String badge,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          PhotoAuditViewerDialog.show(
            context,
            title: title,
            subtitle: subtitle,
            imagePath: imagePath,
            badgeLabel: badge,
            badgeColor: badgeColor,
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: ApiEndpoints.resolveImageUrl(imagePath),
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 54,
                    height: 54,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: badgeColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.zoom_in, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
