import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String name;
  const OtpScreen({super.key, required this.phone, required this.name});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _pinController = TextEditingController();
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      return _resendCountdown > 0;
    });
  }

  Future<void> _verify(String code) async {
    final success = await ref.read(authProvider.notifier).verifyOtp(widget.phone, code);
    if (!mounted) return;
    if (!success) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Invalid code'), backgroundColor: AppTheme.danger));
      _pinController.clear();
    }
    // On success: router redirect fires automatically when authProvider.user is set
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    final defaultPinTheme = PinTheme(
      width: 56, height: 60,
      textStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Verify phone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.sms_outlined, color: AppTheme.primary, size: 64),
              const SizedBox(height: 24),
              const Text('Enter verification code',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text('We sent a 6-digit code to ${widget.phone}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),

              Pinput(
                controller: _pinController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                onCompleted: isLoading ? null : _verify,
              ),

              const SizedBox(height: 32),

              if (isLoading)
                const CircularProgressIndicator(color: AppTheme.primary)
              else if (_resendCountdown > 0)
                Text('Resend code in ${_resendCountdown}s',
                    style: const TextStyle(color: AppTheme.textSecondary))
              else
                TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).sendOtp(widget.phone, widget.name);
                    setState(() => _resendCountdown = 60);
                    _startCountdown();
                  },
                  child: const Text('Resend OTP'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
