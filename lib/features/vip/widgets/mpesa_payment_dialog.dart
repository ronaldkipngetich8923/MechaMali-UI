// lib/features/vip/widgets/mpesa_payment_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mechamali/core/network/api_client.dart';
import 'package:mechamali/core/theme/app_theme.dart';

class MpesaPaymentDialog extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String plan;
  final int amount;

  const MpesaPaymentDialog({
    super.key,
    required this.phoneNumber,
    required this.plan,
    required this.amount,
  });

  @override
  ConsumerState<MpesaPaymentDialog> createState() => _MpesaPaymentDialogState();
}

class _MpesaPaymentDialogState extends ConsumerState<MpesaPaymentDialog> {
  String _status = 'initiating';
  String? _checkoutRequestId;

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/payments/mpesa/stkpush', data: {
        'phoneNumber': widget.phoneNumber,
        'amount': widget.amount,
        'plan': widget.plan,
      });

      setState(() {
        _checkoutRequestId = response.data['CheckoutRequestID'];
        _status = 'pending';
      });

      // Poll for payment status
      _pollPaymentStatus();

    } catch (e) {
      setState(() => _status = 'error');
    }
  }

  Future<void> _pollPaymentStatus() async {
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final status = await _checkPaymentStatus();
      if (status == 'completed') {
        setState(() => _status = 'completed');
        _onSuccess();
        break;
      } else if (status == 'failed') {
        setState(() => _status = 'failed');
        break;
      }
    }
  }

  Future<String> _checkPaymentStatus() async {
    // Implementation to check payment status
    return 'pending';
  }

  void _onSuccess() {
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Payment successful! Welcome to VIP!'),
        backgroundColor: AppTheme.primary,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(height: 16),
            Text(_buildStatusMessage(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_buildStatusSubMessage(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            if (_status == 'pending') ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Check your phone for M-Pesa prompt\nEnter PIN to complete payment',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
            if (_status == 'error' || _status == 'failed')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case 'initiating':
        return const Icon(Icons.sync, size: 48, color: AppTheme.primary);
      case 'pending':
        return const Icon(Icons.phone_android, size: 48, color: AppTheme.accent);
      case 'completed':
        return const Icon(Icons.check_circle, size: 48, color: AppTheme.primary);
      case 'error':
      case 'failed':
        return const Icon(Icons.error, size: 48, color: AppTheme.danger);
      default:
        return const SizedBox.shrink();
    }
  }

  String _buildStatusMessage() {
    switch (_status) {
      case 'initiating': return 'Initiating M-Pesa...';
      case 'pending': return 'Check Your Phone';
      case 'completed': return 'Payment Successful! 🎉';
      case 'failed': return 'Payment Failed';
      default: return '';
    }
  }

  String _buildStatusSubMessage() {
    switch (_status) {
      case 'pending':
        return 'Enter your M-Pesa PIN to complete payment';
      case 'failed':
        return 'Please try again or use another payment method';
      default:
        return '';
    }
  }
}