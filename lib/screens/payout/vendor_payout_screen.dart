import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_payout_model.dart';
import '../../providers/vendor_payout_provider.dart';

class VendorPayoutScreen extends StatefulWidget {
  const VendorPayoutScreen({super.key});

  @override
  State<VendorPayoutScreen> createState() => _VendorPayoutScreenState();
}

class _VendorPayoutScreenState extends State<VendorPayoutScreen> {
  void _showRequestPayoutModal(BuildContext context, VendorPayoutModel? data) {
    if (data == null) return;

    if (!data.isBankConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please link your commercial bank account before requesting withdrawal.'),
          backgroundColor: AppColors.error,
        ),
      );
      _showUpdateBankModal(context);
      return;
    }

    final withdrawableDouble = double.tryParse(data.withdrawableBalance) ?? 0.0;
    final amountController = TextEditingController();
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provider = context.watch<VendorPayoutProvider>();

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Request Merchant Payout',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Disbursement destination: ${data.bankName} (${data.accountNumberMasked})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  if (data.isCooldownActive) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '48-Hour Cooldown Active (${data.hoursRemaining}h left): Payout requests placed now will be audited once the fraud-prevention cooldown window elapses.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Available Balance Snapshot
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Available Cleared Balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text(
                          CurrencyFormatter.format(data.withdrawableBalance),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('WITHDRAWAL AMOUNT (₦) *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () {
                          if (withdrawableDouble > 0) {
                            amountController.text = withdrawableDouble.toStringAsFixed(2);
                            setModalState(() => localError = null);
                          }
                        },
                        child: const Text('WITHDRAW ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryPurple)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '₦ ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                      hintText: 'Min ₦1,000.00',
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Text(localError!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final text = amountController.text.trim();
                              final amount = double.tryParse(text);

                              if (amount == null || amount < 1000) {
                                setModalState(() => localError = 'Minimum payout withdrawal is ₦1,000.00.');
                                return;
                              }

                              if (amount > withdrawableDouble) {
                                setModalState(() => localError = 'Requested amount exceeds your cleared withdrawable balance (₦${data.withdrawableBalance}).');
                                return;
                              }

                              final res = await provider.requestPayout(amount);

                              if (res['success'] == true) {
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Payout request submitted.'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                setModalState(() => localError = res['message']);
                              }
                            },
                      child: provider.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Payout Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUpdateBankModal(BuildContext context) {
    final bankController = TextEditingController();
    final accountNumController = TextEditingController();
    final accountNameController = TextEditingController();
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provider = context.watch<VendorPayoutProvider>();

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Update Settlement Bank Details',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '⚠️ Anti-Fraud Notice: Updating bank details immediately triggers an automatic 48-hour security cooldown on disbursements.',
                    style: TextStyle(fontSize: 12, color: AppColors.warning, height: 1.35, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  const Text('BANK NAME *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: bankController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Zenith Bank, Access Bank',
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('10-DIGIT NUBAN ACCOUNT NUMBER *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: accountNumController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '10 digits',
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('ACCOUNT BENEFICIARY NAME *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: accountNameController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g. APEX ENTERPRISES',
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Text(localError!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final bank = bankController.text.trim();
                              final accNum = accountNumController.text.trim();
                              final accName = accountNameController.text.trim();

                              if (bank.isEmpty || accNum.length != 10 || accName.isEmpty) {
                                setModalState(() => localError = 'Please provide bank name, 10-digit NUBAN, and account name.');
                                return;
                              }

                              final res = await provider.updateBank(
                                bankName: bank,
                                accountNumber: accNum,
                                accountName: accName,
                              );

                              if (res['success'] == true) {
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Bank account updated. 48h Cooldown active.'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                setModalState(() => localError = res['message']);
                              }
                            },
                      child: provider.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Update & Activate 48h Cooldown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorPayoutProvider>();
    final data = provider.payoutData;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Sovereign Payout & Treasury'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : RefreshIndicator(
              color: AppColors.primaryPurple,
              onRefresh: () => provider.fetchPayouts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linked Settlement Bank Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('LINKED SETTLEMENT ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                                icon: const Icon(Icons.edit, size: 14, color: AppColors.primaryPurple),
                                label: const Text('Edit Bank', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primaryPurple)),
                                onPressed: () => _showUpdateBankModal(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data?.bankName ?? 'No Bank Linked',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data?.accountNumberMasked ?? '••••••••••',
                            style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          Text(
                            data?.accountName ?? '',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const Divider(height: 20),

                          // Cooldown Status Badge
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: data?.isCooldownActive == true ? const Color(0xFFFFFBEB) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  data?.isCooldownActive == true ? Icons.security : Icons.check_circle,
                                  size: 16,
                                  color: data?.isCooldownActive == true ? AppColors.warning : AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data?.isCooldownActive == true
                                        ? '48-Hour Cooldown Active (${data?.hoursRemaining}h left): Security hold on automated bank disbursements.'
                                        : 'Account Verified: Standard daily automated disbursements active.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: data?.isCooldownActive == true ? const Color(0xFF92400E) : const Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Unrecovered Debt Warning Banner
                    if (data != null && data.hasUnrecoveredDebt) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Outstanding Return / Liability Deductions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₦${data.unrecoveredDebt} is pending recovery from customer refunds or returns. This liability is automatically subtracted from newly cleared earnings.',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B), height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // FinTech 4-Card Balances Suite
                    // 1. Withdrawable Balance (Prominent Card)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981)),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('WITHDRAWABLE BALANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFF065F46), borderRadius: BorderRadius.circular(6)),
                                child: const Text('CLEARED', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(data?.withdrawableBalance ?? '0.00'),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Cleared funds ready for bank transfer. In-transit orders remain held in escrow.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.account_balance_wallet, size: 18),
                              label: const Text('Request Payout Withdrawal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              onPressed: () => _showRequestPayoutModal(context, data),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Grid of other 3 balances: Escrow Held, Pending Payout, Total Settled
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricMiniCard(
                            title: 'In Escrow (Held)',
                            amount: data?.escrowHeldBalance ?? '0.00',
                            color: const Color(0xFF8B5CF6),
                            subtext: 'Awaiting delivery + 24h',
                            icon: Icons.lock_clock,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricMiniCard(
                            title: 'Pending Payout',
                            amount: data?.pendingPayoutBalance ?? '0.00',
                            color: const Color(0xFFF59E0B),
                            subtext: 'Under treasury review',
                            icon: Icons.hourglass_top,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildMetricMiniCard(
                      title: 'Total Settled (Net 90% Lifetime)',
                      amount: data?.totalSettledBalance ?? '0.00',
                      color: const Color(0xFF10B981),
                      subtext: 'Authoritatively disbursed into verified merchant bank accounts.',
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 24),

                    // Recent Payout Requests Queue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RECENT PAYOUT REQUESTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        Text('${data?.payoutRequests.length ?? 0} records', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: (data?.payoutRequests.isEmpty ?? true)
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('No payout requests yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data!.payoutRequests.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final req = data.payoutRequests[i];
                                Color statusColor;
                                String statusLabel;

                                if (req.isDisbursed) {
                                  statusColor = AppColors.success;
                                  statusLabel = 'DISBURSED';
                                } else if (req.isApproved) {
                                  statusColor = Colors.blue;
                                  statusLabel = 'APPROVED';
                                } else if (req.isRejected) {
                                  statusColor = AppColors.error;
                                  statusLabel = 'REJECTED';
                                } else {
                                  statusColor = AppColors.warning;
                                  statusLabel = 'PENDING AUDIT';
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(req.amount),
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${req.bankName} • ${req.accountNumberMasked}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          Text(
                                            req.createdAt != null && req.createdAt!.length >= 10 ? req.createdAt!.substring(0, 10) : '',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      if (req.isRejected && req.rejectionReason != null) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
                                          child: Text('Reason: ${req.rejectionReason}', style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Settled Orders Audit Table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SETTLED ORDERS AUDIT LOG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        Text('${data?.settledHistory.length ?? 0} settled', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: (data?.settledHistory.isEmpty ?? true)
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('No settled payouts yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data!.settledHistory.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final record = data.settledHistory[i];
                                return ListTile(
                                  title: Text(record.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  subtitle: Text(record.settledAt ?? 'Settled', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  trailing: Text(
                                    CurrencyFormatter.format(record.vendorNet90),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.success),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricMiniCard({
    required String title,
    required String amount,
    required Color color,
    required String subtext,
    required IconData icon,
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
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
