import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class InspectionCodeDialog extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(String code) onVerify;

  const InspectionCodeDialog({super.key, required this.onVerify});

  static Future<void> show(
    BuildContext context, {
    required Future<Map<String, dynamic>> Function(String code) onVerify,
  }) {
    return showDialog(
      context: context,
      builder: (_) => InspectionCodeDialog(onVerify: onVerify),
    );
  }

  @override
  State<InspectionCodeDialog> createState() => _InspectionCodeDialogState();
}

class _InspectionCodeDialogState extends State<InspectionCodeDialog> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length < 5) {
      setState(() => _error = 'Please enter a valid RES reservation code.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final res = await widget.onVerify(code);

    if (!mounted) return;

    if (res['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Inspection pass confirmed! Customer may now proceed to payment.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() {
        _isVerifying = false;
        _error = res['message'] ?? 'Verification failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryGold.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_2, color: AppColors.secondaryGold, size: 28),
          ),
          const SizedBox(height: 10),
          const Text(
            'In-Shop Inspection Signoff',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const Text(
            '₦0.00 Upfront Customer Reservation',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter the 8-character RES pass code presented by the customer following physical item inspection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.primaryPurple,
            ),
            decoration: InputDecoration(
              hintText: 'RES-XXXXXXXX',
              filled: true,
              fillColor: AppColors.scaffoldBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isVerifying ? null : _submit,
          child: _isVerifying
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Sign Off Pass', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ],
    );
  }
}
