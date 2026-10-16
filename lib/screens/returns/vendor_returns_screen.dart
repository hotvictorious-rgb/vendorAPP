import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_return_model.dart';
import '../../providers/vendor_returns_provider.dart';
import '../../widgets/photo_audit_viewer_dialog.dart';
import '../../widgets/return_dispute_dialog.dart';

class VendorReturnsScreen extends StatefulWidget {
  const VendorReturnsScreen({super.key});

  @override
  State<VendorReturnsScreen> createState() => _VendorReturnsScreenState();
}

class _VendorReturnsScreenState extends State<VendorReturnsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorReturnsProvider>().fetchReturns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorReturnsProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Inbound Returns & Disputes'),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, label: 'All Cases', status: 'all', selected: provider.selectedStatus == 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'In Transit', status: 'in_transit_back_to_vendor', selected: provider.selectedStatus == 'in_transit_back_to_vendor'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'Returned to Shop', status: 'returned_to_vendor', selected: provider.selectedStatus == 'returned_to_vendor'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'Disputed', status: 'disputed_by_vendor', selected: provider.selectedStatus == 'disputed_by_vendor'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'Resolved', status: 'resolved', selected: provider.selectedStatus == 'resolved'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Return Cases List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                : provider.returnCases.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryPurple,
                        onRefresh: () => provider.fetchReturns(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.returnCases.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final returnCase = provider.returnCases[index];
                            return _buildReturnCard(context, returnCase);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String status,
    required bool selected,
  }) {
    final provider = context.read<VendorReturnsProvider>();

    return FilterChip(
      selected: selected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      selectedColor: AppColors.primaryPurple,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? AppColors.primaryPurple : AppColors.border),
      ),
      onSelected: (_) => provider.setFilterStatus(status),
    );
  }

  Widget _buildReturnCard(BuildContext context, VendorReturnModel returnCase) {
    final provider = context.read<VendorReturnsProvider>();

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusColor = const Color(0xFFB45309);
    String statusLabel = returnCase.status.replaceAll('_', ' ').toUpperCase();

    if (returnCase.isDisputed) {
      statusBg = const Color(0xFFFEF2F2);
      statusColor = AppColors.error;
      statusLabel = 'DISPUTED BY MERCHANT';
    } else if (returnCase.isReturnedToShop) {
      statusBg = const Color(0xFFDCFCE7);
      statusColor = const Color(0xFF15803D);
      statusLabel = 'RETURNED TO SHOP';
    } else if (returnCase.isResolved) {
      statusBg = const Color(0xFFF3E8FF);
      statusColor = AppColors.primaryPurple;
      statusLabel = returnCase.adminRuling != null ? 'ARBITRATED: ${returnCase.adminRuling!.replaceAll('_', ' ').toUpperCase()}' : 'RESOLVED';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: returnCase.isDisputed ? const Color(0xFFFECACA) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Case Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                returnCase.caseNumber,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Order #${returnCase.orderNumber} • Claim: ${returnCase.returnReason.replaceAll('_', ' ').toUpperCase()}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),

          if (returnCase.customerDescription != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Customer Claim: "${returnCase.customerDescription}"',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
              ),
            ),
          ],

          const Divider(height: 20),

          // Items summary
          if (returnCase.items.isNotEmpty) ...[
            ...returnCase.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.productName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.refundableAmount),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 📸 Evidence Photo Snaps Row
          if (returnCase.hasEvidencePhotos) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 14, color: AppColors.primaryPurple),
                      SizedBox(width: 6),
                      Text(
                        'IMMUTABLE EVIDENCE SNAPS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (returnCase.doorstepPhotoPath != null)
                          _buildEvidenceThumb(
                            context,
                            label: 'Doorstep Rejection',
                            imagePath: returnCase.doorstepPhotoPath!,
                            badgeColor: Colors.red,
                          ),
                        if (returnCase.vendorReturnPhotoPath != null)
                          _buildEvidenceThumb(
                            context,
                            label: 'Shop Return Snap',
                            imagePath: returnCase.vendorReturnPhotoPath!,
                            badgeColor: const Color(0xFF7E22CE),
                          ),
                        if (returnCase.vendorDisputePhotoPath != null)
                          _buildEvidenceThumb(
                            context,
                            label: 'Merchant Counter-Proof',
                            imagePath: returnCase.vendorDisputePhotoPath!,
                            badgeColor: const Color(0xFFBE123C),
                          ),
                        ...returnCase.items.where((i) => i.defectPhotoPath != null).map((i) {
                          return _buildEvidenceThumb(
                            context,
                            label: '${i.productName} Defect',
                            imagePath: i.defectPhotoPath!,
                            badgeColor: Colors.orange,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Courier Handshake Return OTP Card
          if (returnCase.vendorReturnOtp != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key, color: AppColors.primaryPurple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SHOP RETURN HANDSHAKE OTP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primaryPurple)),
                        Text(returnCase.vendorReturnOtp!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2, color: Color(0xFF581C87))),
                      ],
                    ),
                  ),
                  const Text('Rider verification code', style: TextStyle(fontSize: 10, color: Color(0xFF7E22CE))),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // If Merchant Disputed: Show Dispute Reason Banner
          if (returnCase.vendorDisputed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.error),
                      SizedBox(width: 6),
                      Text('MERCHANT COUNTER-DISPUTE FILED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    returnCase.vendorDisputeReason ?? 'Item condition rejected by vendor at shop counter.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9F1239)),
                  ),
                  if (returnCase.adminRuling != null) ...[
                    const Divider(height: 14),
                    Text(
                      'Super Admin Ruling: ${returnCase.adminRuling!.replaceAll('_', ' ').toUpperCase()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF881337)),
                    ),
                  ],
                ],
              ),
            ),
          ] else if (returnCase.status != 'resolved' && returnCase.status != 'refunded') ...[
            // Action to Flag Dispute
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.gavel, size: 16),
                label: const Text('Inspect & Dispute Return Condition', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                onPressed: () {
                  ReturnDisputeDialog.show(
                    context,
                    returnCase: returnCase,
                    onSubmitDispute: (reason) => provider.disputeReturn(
                      caseNumber: returnCase.caseNumber,
                      disputeReason: reason,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvidenceThumb(
    BuildContext context, {
    required String label,
    required String imagePath,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          PhotoAuditViewerDialog.show(
            context,
            title: label,
            subtitle: 'Immutable proof anchored to return case',
            imagePath: imagePath,
            badgeLabel: label,
            badgeColor: badgeColor,
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: ApiEndpoints.resolveImageUrl(imagePath),
                width: 72,
                height: 54,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 72,
                  height: 54,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: badgeColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.assignment_return_outlined, size: 48, color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 16),
          const Text('No Inbound Returns', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('All delivered customer orders are currently in good standing.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
