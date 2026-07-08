import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/splash_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to initialization provider
    ref.listen<AsyncValue<bool>>(splashInitProvider, (previous, next) {
      if (next.hasValue && next.value == true) {
        // Navigate to onboarding screen
        context.go('/onboarding');
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            )
                .animate()
                .fade(duration: 800.ms)
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .then(delay: 200.ms)
                .shimmer(duration: 1200.ms),

            const SizedBox(height: 24),

            // Animated App Title
            Text(
              'ModarApp Store',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fade(duration: 800.ms, delay: 300.ms)
                .slideY(begin: 0.2, end: 0.0, curve: Curves.easeOutQuad, duration: 800.ms),

            const SizedBox(height: 8),

            // Animated Subtitle
            Text(
              'Your Premium Marketplace',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                letterSpacing: 1.0,
              ),
            )
                .animate()
                .fade(duration: 800.ms, delay: 500.ms)
                .slideY(begin: 0.3, end: 0.0, curve: Curves.easeOutQuad, duration: 800.ms),

            const SizedBox(height: 64),

            // Spinner loader
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
                .animate()
                .fade(duration: 600.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
