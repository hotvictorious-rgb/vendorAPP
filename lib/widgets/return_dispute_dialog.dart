import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/vendor_return_model.dart';

class ReturnDisputeDialog {
  static void show(
    BuildContext context, {
    required VendorReturnModel returnCase,
    required Future<Map<String, dynamic>> Function(String reason) onSubmitDispute,
  }) {
    final reasonController = TextEditingController();
    bool isSubmitting = false;
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
              child: SingleChildScrollView(
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          returnCase.caseNumber,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Text(
                            'ARBITRATION SHIELD',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order: ${returnCase.orderNumber} • Stated Reason: ${returnCase.returnReason.replaceAll('_', ' ').toUpperCase()}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),

                    if (returnCase.customerDescription != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Customer Note: "${returnCase.customerDescription}"',
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // Courier Handshake Return OTP Card
                    if (returnCase.vendorReturnOtp != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD8B4FE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.pin, color: AppColors.primaryPurple, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'COURIER RETURN HANDSHAKE OTP',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryPurple),
                                  ),
                                  Text(
                                    returnCase.vendorReturnOtp!,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3, color: Color(0xFF581C87)),
                                  ),
                                  const Text(
                                    'Share with delivery rider only after parcel inspection.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF7E22CE)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Counter Dispute Reason Field
                    const Text(
                      'DISPUTE RETURN CONDITION *',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Detail why this item cannot be accepted (e.g. Swapped serial number, broken security seal, customer physical damage)...',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: AppColors.scaffoldBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),

                    if (localError != null) ...[
                      const SizedBox(height: 8),
                      Text(localError!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: isSubmitting
                            ? const SizedBox.shrink()
                            : const Icon(Icons.gavel, color: Colors.white, size: 18),
                        label: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'Escalate to Super Admin Arbitration Desk',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                              ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final text = reasonController.text.trim();
                                if (text.length < 5) {
                                  setState(() => localError = 'Please provide a detailed dispute reason (minimum 5 characters).');
                                  return;
                                }

                                setState(() {
                                  isSubmitting = true;
                                  localError = null;
                                });

                                final res = await onSubmitDispute(text);

                                if (res['success'] == true) {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res['message'] ?? 'Dispute escalated to Super Admin successfully.'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    isSubmitting = false;
                                    localError = res['message'] ?? 'Failed to submit dispute.';
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
