import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';

class FintechBalanceCard extends StatelessWidget {
  final String businessName;
  final String netEarnings;
  final String pendingEscrow;
  final String? withdrawableBalance;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onScanInspection;
  final VoidCallback onVerifyHandover;

  const FintechBalanceCard({
    super.key,
    required this.businessName,
    required this.netEarnings,
    required this.pendingEscrow,
    this.withdrawableBalance,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.onScanInspection,
    required this.onVerifyHandover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF281158),
            Color(0xFF140733),
            Color(0xFF0D0422),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.secondaryGold.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Background ambient sheen
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryGold.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGold.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.secondaryGold.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified, color: AppColors.secondaryGold, size: 13),
                              SizedBox(width: 5),
                              Text(
                                'SOVEREIGN 90% ESCROW',
                                style: TextStyle(
                                  color: AppColors.secondaryGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                      tooltip: isBalanceVisible ? 'Hide Balance' : 'Show Balance',
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Merchant Business Name
                Text(
                  businessName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Net 90% Available Balance
                Text(
                  isBalanceVisible
                      ? CurrencyFormatter.format(withdrawableBalance ?? netEarnings)
                      : '₦ • • • • • •',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Escrow & Cleared Sub-label
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      withdrawableBalance != null ? 'Cleared' : 'Net Sales',
                      style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Escrow: ${isBalanceVisible ? CurrencyFormatter.format(pendingEscrow) : '₦ ••••'}',
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Action Bar: Scan Pass & Verify Handover
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryGold,
                          foregroundColor: const Color(0xFF1E1B4B),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.qr_code_scanner, size: 16),
                        label: const Text(
                          'Inspection Pass',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        onPressed: onScanInspection,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.local_shipping, size: 16),
                        label: const Text(
                          'Verify Courier',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        onPressed: onVerifyHandover,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
