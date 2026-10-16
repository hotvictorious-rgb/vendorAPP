import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/vendor_payout_provider.dart';

class VendorPayoutScreen extends StatefulWidget {
  const VendorPayoutScreen({super.key});

  @override
  State<VendorPayoutScreen> createState() => _VendorPayoutScreenState();
}

class _VendorPayoutScreenState extends State<VendorPayoutScreen> {
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
        title: const Text('Sovereign Payout & Ledger'),
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
                    // Bank Details & Cooldown Card
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
                    const SizedBox(height: 18),

                    // Ledger Sums Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Settled (Net 90%)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(data?.settledSum ?? '0.00'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Eligible for Payout', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(data?.eligibleSum ?? '0.00'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryPurple),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Settled Orders History Table
                    const Text('SETTLED ORDERS AUDIT LOG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
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
                  ],
                ),
              ),
            ),
    );
  }
}
