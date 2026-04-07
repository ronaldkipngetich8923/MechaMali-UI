import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingPage(this.icon, this.title, this.subtitle);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = const [
    _OnboardingPage(Icons.bolt_rounded,       'Live Scores',       'Follow KPL, EPL, and CAF matches in real time.'),
    _OnboardingPage(Icons.psychology_rounded,  'AI Insights',       'Get AI-powered pre-match analysis tailored to each game.'),
    _OnboardingPage(Icons.notifications_active_rounded, 'Smart Alerts', 'Get notified for goals, kick-offs and key events.'),
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, color: AppTheme.primaryLight, size: 60),
                        ),
                        const SizedBox(height: 40),
                        Text(page.title,
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(page.subtitle,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, height: 1.6),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppTheme.primary : AppTheme.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/auth/phone'),
                    child: const Text('Get Started'),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300), curve: Curves.ease),
                      child: const Text('Next'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
