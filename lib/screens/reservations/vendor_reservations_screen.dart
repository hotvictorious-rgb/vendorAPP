import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_reservation_model.dart';
import '../../providers/vendor_reservations_provider.dart';
import '../../widgets/inspection_code_dialog.dart';

class VendorReservationsScreen extends StatelessWidget {
  const VendorReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorReservationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('In-Shop Inspection Passes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: 'Sign Off Pass',
            onPressed: () {
              InspectionCodeDialog.show(
                context,
                onVerify: (code) => provider.verifyInspection(code),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : provider.reservations.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  color: AppColors.primaryPurple,
                  onRefresh: () => provider.fetchReservations(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.reservations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = provider.reservations[index];
                      return _buildReservationCard(context, item);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.qr_code_2, color: Colors.white),
        label: const Text('Sign Off Pass', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        onPressed: () {
          InspectionCodeDialog.show(
            context,
            onVerify: (code) => provider.verifyInspection(code),
          );
        },
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, VendorReservationModel res) {
    final provider = context.read<VendorReservationsProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  res.reservationCode,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryPurple),
                ),
              ),
              _buildStatusBadge(res.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(res.productName ?? 'Reserved Product', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 3),
          Text(
            '${CurrencyFormatter.format(res.productPrice ?? '0')} • Qty: ${res.quantity} (₦0.00 Paid Upfront)',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Shopper: ${res.customerName ?? 'Customer'} • ${res.customerPhone ?? 'No Phone'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (res.isPending) ...[
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.verified, size: 16),
                label: const Text('Confirm Physical Inspection', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                onPressed: () => provider.verifyInspection(res.reservationCode),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPending = status == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPending ? 'PENDING IN-SHOP VISIT' : 'INSPECTED & APPROVED',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.qr_code_2_outlined, size: 54, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No active inspection passes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('When shoppers lock ₦0.00 items to inspect in your shop, passes show here.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
