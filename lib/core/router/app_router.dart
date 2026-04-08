// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/betting_tutorial_screen.dart';
import '../../features/auth/screens/phone_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/match_detail/screens/match_detail_screen.dart';
import '../../features/vip/screens/vip_paywall_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/betting_stats_screen.dart';
import '../../features/home/screens/main_scaffold.dart';
import '../../features/home/screens/betting_tips_screen.dart';
import '../../features/watchlist/screens/watchlist_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen(authProvider, (_, next) => authNotifier.value = next);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuth = authNotifier.value.isAuthenticated;
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isAuthFlow = loc.startsWith('/auth') || loc == '/onboarding';
      final isPublicRoute = loc == '/tutorial'; // Tutorial is public

      if (isSplash) return null;
      if (isPublicRoute) return null;

      if (!isAuth && !isAuthFlow) return '/onboarding';
      if (isAuth && isAuthFlow) return '/home';

      return null;
    },
    routes: [
      // Public routes
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/tutorial', builder: (_, __) => const BettingTutorialScreen()),
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OtpScreen(phone: extra['phone'] as String, name: extra['name'] as String);
        },
      ),

      // Main app with shell
      ShellRoute(
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/betting-tips', builder: (_, __) => const BettingTipsScreen()),
          GoRoute(path: '/betting-stats', builder: (_, __) => const BettingStatsScreen()),
          GoRoute(path: '/watchlist', builder: (_, __) => const WatchlistScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        ],
      ),

      // Detail routes
      GoRoute(
        path: '/match/:id',
        builder: (_, state) => MatchDetailScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/vip', builder: (_, __) => const VipPaywallScreen()),
    ],
  );
});