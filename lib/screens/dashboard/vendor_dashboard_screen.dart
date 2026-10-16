import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../../providers/vendor_orders_provider.dart';
import '../../providers/vendor_reservations_provider.dart';
import '../../widgets/fintech_balance_card.dart';
import '../../widgets/cooldown_hud_card.dart';
import '../../widgets/inspection_code_dialog.dart';
import '../account/vendor_account_screen.dart';
import '../products/add_product_screen.dart';
import '../returns/vendor_returns_screen.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<VendorDashboardProvider>();
    final auth = context.watch<VendorAuthProvider>();
    final reservations = context.read<VendorReservationsProvider>();
    final data = dash.dashboardData;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  data?.shop?.name ?? 'Merchant Storefront',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF1E1B4B)),
                  ),
                ),
              ],
            ),
            Text(
              data?.shop?.lgaName ?? 'Akwa Ibom Commercial Corridor',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_return_outlined, color: Colors.white),
            tooltip: 'Inbound Returns',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VendorReturnsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'Account Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VendorAccountScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryPurple,
        onRefresh: () async {
          await Future.wait([
            dash.fetchDashboard(),
            context.read<VendorOrdersProvider>().fetchOrders(),
            reservations.fetchReservations(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FinTech Obsidian Balance Card
              FintechBalanceCard(
                businessName: data?.merchant.businessName ?? auth.currentUser?.name ?? 'Merchant',
                netEarnings: data?.financialMetrics.net90Earnings ?? '0.00',
                pendingEscrow: data?.financialMetrics.pendingEscrow ?? '0.00',
                isBalanceVisible: dash.isBalanceVisible,
                onToggleVisibility: dash.toggleBalanceVisibility,
                onScanInspection: () {
                  InspectionCodeDialog.show(
                    context,
                    onVerify: (code) => reservations.verifyInspection(code),
                  );
                },
                onVerifyHandover: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Select an order from the Orders tab to verify courier PIN handover.'),
                      backgroundColor: AppColors.primaryPurple,
                    ),
                  );
                },
              ),

              // 48-Hour Bank Cooldown Warning HUD
              if (data != null && data.securityCooldown.isActive)
                CooldownHudCard(
                  isActive: data.securityCooldown.isActive,
                  hoursRemaining: data.securityCooldown.hoursRemaining,
                  bankName: data.securityCooldown.bankName,
                  maskedAccountNumber: data.securityCooldown.accountNumberMasked,
                ),

              const SizedBox(height: 20),

              // Telemetry Grid
              const Text(
                'LIVE STOREFRONT TELEMETRY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Active Orders',
                      value: '${data?.ordersBreakdown.processing ?? 0}',
                      subtitle: 'Awaiting Courier Handover',
                      icon: Icons.local_shipping_outlined,
                      iconColor: AppColors.primaryPurple,
                      bgColor: const Color(0xFFF3E8FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Inspection Passes',
                      value: '${data?.reservationsBreakdown.activePending ?? 0}',
                      subtitle: '₦0.00 Down In-Store',
                      icon: Icons.qr_code_2,
                      iconColor: AppColors.goldAccent,
                      bgColor: const Color(0xFFFEF3C7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Delivered',
                      value: '${data?.ordersBreakdown.delivered ?? 0}',
                      subtitle: 'Handover Completed',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      bgColor: const Color(0xFFDCFCE7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Active Products',
                      value: '${data?.inventorySummary.totalProducts ?? 0}',
                      subtitle: '7-Day Freshness',
                      icon: Icons.inventory_2_outlined,
                      iconColor: AppColors.info,
                      bgColor: const Color(0xFFDBEAFE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TERMINAL ACTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddProductScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryPurple,
                              side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.verified, size: 18),
                            label: const Text('Sign Off Pass', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            onPressed: () {
                              InspectionCodeDialog.show(
                                context,
                                onVerify: (code) => reservations.verifyInspection(code),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9333EA),
                          side: const BorderSide(color: Color(0xFFD8B4FE), width: 1.2),
                          backgroundColor: const Color(0xFFFAF5FF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.assignment_return_outlined, size: 18),
                        label: const Text('Inbound Returns & Dispute Desk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VendorReturnsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
