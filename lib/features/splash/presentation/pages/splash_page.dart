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

    // Listen to initialization provider
    ref.listen<AsyncValue<bool>>(splashInitProvider, (previous, next) {
      if (next.hasValue && next.value == true) {
        context.go('/onboarding');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Deep Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B3322), // Signature Deep Emerald
                  Color(0xFF041910), // Midnight Teal
                  Color(0xFF020E0A), // Rich Black Forest
                ],
              ),
            ),
          ),

          // 2. Decorative Atmospheric Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0E7F53).withOpacity(0.12),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.06),
              ),
              child: const SizedBox.shrink(),
            ),
          ),

          // 3. Main Branded Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded Emblem
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.easeOutBack)
                        .rotate(duration: 2000.ms, begin: -0.1, end: 0.1, curve: Curves.easeInOutSine),

                    // Inner Emblem Card
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0E7F53),
                            Color(0xFF074D32),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E7F53).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_mall_rounded, // Premium shopping bag icon
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 800.ms, delay: 100.ms, curve: Curves.easeOutBack)
                        .then(delay: 200.ms)
                        .shimmer(duration: 1200.ms),
                  ],
                ),
                const SizedBox(height: 32),

                // Branded App Title (MODAR | APPID)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MODAR',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'APPID',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.amber, // Gold Accent color
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fade(duration: 800.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0.0, curve: Curves.easeOutQuad, duration: 800.ms)
                    .then(delay: 100.ms)
                    .shimmer(duration: 1500.ms),

                const SizedBox(height: 10),

                // Branded Tagline
                Text(
                  'UNVEIL YOUR SIGNATURE STYLE',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.5,
                  ),
                )
                    .animate()
                    .fade(duration: 800.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0.0, curve: Curves.easeOutQuad, duration: 800.ms),
              ],
            ),
          ),

          // 4. Premium Bottom Loading Bar & Trust Badge
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Flipkart/Amazon-style sleek horizontal progress loader
                Container(
                  width: 140,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.forward())
                        .custom(
                          duration: 2500.ms,
                          builder: (context, value, child) {
                            return SizedBox(
                              width: 140 * value,
                              child: child,
                            );
                          },
                        ),
                  ),
                )
                    .animate()
                    .fade(duration: 400.ms, delay: 700.ms),

                const SizedBox(height: 24),

                // Trust Badge at the very bottom
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security_rounded,
                      size: 13,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '100% SECURE SHOPPING',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fade(duration: 800.ms, delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
