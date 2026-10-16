import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class HandoverOtpDialog extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final Future<Map<String, dynamic>> Function(String otp) onVerify;

  const HandoverOtpDialog({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.onVerify,
  });

  static Future<void> show(
    BuildContext context, {
    required int orderId,
    required String orderNumber,
    required Future<Map<String, dynamic>> Function(String otp) onVerify,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => HandoverOtpDialog(
        orderId: orderId,
        orderNumber: orderNumber,
        onVerify: onVerify,
      ),
    );
  }

  @override
  State<HandoverOtpDialog> createState() => _HandoverOtpDialogState();
}

class _HandoverOtpDialogState extends State<HandoverOtpDialog> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      setState(() => _error = 'Please enter a valid 6-digit courier PIN.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final res = await widget.onVerify(otp);

    if (!mounted) return;

    if (res['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Handover successfully verified!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() {
        _isVerifying = false;
        _error = res['message'] ?? 'Handover verification failed.';
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
              color: AppColors.primaryPurple.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_clock, color: AppColors.primaryPurple, size: 28),
          ),
          const SizedBox(height: 10),
          const Text(
            'Courier Handover PIN',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          Text(
            'Order #${widget.orderNumber}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Request the secret 6-digit handover PIN from the assigned dispatch courier before releasing packages.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              color: AppColors.primaryPurple,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••',
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
              : const Text('Verify & Release', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ],
    );
  }
}
