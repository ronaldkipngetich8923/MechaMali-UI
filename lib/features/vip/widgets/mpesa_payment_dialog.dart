// lib/features/vip/widgets/mpesa_payment_dialog.dart
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

      if (!mounted) return;
      setState(() {
        _checkoutRequestId = response.data['CheckoutRequestID'] as String?;
        _status = 'pending';
      });

      _pollPaymentStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'error');
    }
  }

  Future<void> _pollPaymentStatus() async {
    // FIX: poll up to 30 times (60 s total), checking mounted at every step
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return; // widget was disposed — stop silently

      final status = await _checkPaymentStatus();
      if (!mounted) return;

      if (status == 'completed') {
        setState(() => _status = 'completed');
        _onSuccess();
        return;
      } else if (status == 'failed' || status == 'cancelled') {
        setState(() => _status = 'failed');
        return;
      }
      // 'pending' — keep polling
    }

    // Timed out after 60 s without a conclusive status
    if (mounted) setState(() => _status = 'failed');
  }

  /// FIX: was always returning 'pending' — now calls the real API endpoint.
  Future<String> _checkPaymentStatus() async {
    if (_checkoutRequestId == null) return 'failed';

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/payments/mpesa/status',
        queryParameters: {'checkoutRequestId': _checkoutRequestId},
      );

      // Expected response: { "status": "completed" | "pending" | "failed" | "cancelled" }
      return (response.data['status'] as String?) ?? 'pending';
    } catch (_) {
      // Network hiccup — treat as still pending and let the loop retry
      return 'pending';
    }
  }

  void _onSuccess() {
    if (!mounted) return;
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
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(height: 16),
            Text(
              _buildStatusMessage(),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _buildStatusSubMessage(),
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (_status == 'pending') ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Check your phone for the M-Pesa prompt\nEnter your PIN to complete payment',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
            if (_status == 'error' || _status == 'failed') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _initiatePayment,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ],
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
        return const Icon(Icons.check_circle, size: 48, color: AppTheme.primaryLight);
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
      case 'pending':    return 'Check Your Phone';
      case 'completed':  return 'Payment Successful! 🎉';
      case 'error':      return 'Could Not Reach M-Pesa';
      case 'failed':     return 'Payment Failed';
      default:           return '';
    }
  }

  String _buildStatusSubMessage() {
    switch (_status) {
      case 'pending':
        return 'Enter your M-Pesa PIN to complete payment';
      case 'error':
        return 'Could not initiate the STK push. Check your connection and try again.';
      case 'failed':
        return 'The payment was not completed. Please try again.';
      default:
        return '';
    }
  }
}