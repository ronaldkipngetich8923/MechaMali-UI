import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class VipPaywallScreen extends ConsumerStatefulWidget {
  const VipPaywallScreen({super.key});

  @override
  ConsumerState<VipPaywallScreen> createState() => _VipPaywallScreenState();
}

class _VipPaywallScreenState extends ConsumerState<VipPaywallScreen> {
  String _selectedPlan = 'VipMonthly';
  bool _isLoading = false;

  final _plans = const [
    _Plan(id: 'VipMonthly',    label: 'Monthly',   price: 'KES 150',  period: 'per month',   badge: ''),
    _Plan(id: 'VipQuarterly',  label: 'Quarterly', price: 'KES 350',  period: 'per 3 months', badge: 'BEST VALUE'),
  ];

  Future<void> _subscribe() async {
    final user = ref.read(authProvider).user;
    if (user == null) { context.push('/auth/phone'); return; }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/payments/mpesa/subscribe', data: {
        'phone': user.phone,
        'plan':  _selectedPlan,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your phone for the M-Pesa prompt!'),
            backgroundColor: AppTheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Try again.'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
        title: const Text('Go VIP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Crown icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.star_rounded, color: AppTheme.accent, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Unlock VIP Insights', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Get the full AI match analysis, win probabilities, and head-to-head stats.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center),

              const SizedBox(height: 32),

              // Features list
              ...[
                ('AI pre-match analysis',         Icons.psychology_rounded),
                ('Win probability scores',         Icons.bar_chart_rounded),
                ('Head-to-head history',           Icons.history_rounded),
                ('Priority match notifications',   Icons.notifications_active_rounded),
                ('Covers KPL, EPL, CAF & more',   Icons.public_rounded),
              ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(f.$2, color: AppTheme.primaryLight, size: 20),
                    const SizedBox(width: 12),
                    Text(f.$1, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              )),

              const SizedBox(height: 32),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 24),

              // Plan selector
              Row(
                children: _plans.map((plan) {
                  final isSelected = _selectedPlan == plan.id;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPlan = plan.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (plan.badge.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(4)),
                                child: Text(plan.badge, style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                            Text(plan.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(plan.price, style: const TextStyle(color: AppTheme.accent, fontSize: 20, fontWeight: FontWeight.w800)),
                            Text(plan.period, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _subscribe,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.phone_android_rounded, size: 18),
                label: Text(_isLoading ? 'Sending M-Pesa prompt...' : 'Pay with M-Pesa'),
              ),

              const SizedBox(height: 12),
              const Text('Secure payment via Safaricom M-Pesa',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Plan {
  final String id, label, price, period, badge;
  const _Plan({required this.id, required this.label, required this.price, required this.period, required this.badge});
}
