import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Find Your Signature Style',
      description: 'Explore our curated range of jackets, hoodies, dresses, footwear, and premium global brands all in one place.',
      icon: Icons.checkroom_rounded,
    ),
    OnboardingItem(
      title: 'Secure & Fast Payment',
      description: 'Multiple secure checkout choices including digital wallets, credit cards, or cash on delivery.',
      icon: Icons.payments_rounded,
    ),
    OnboardingItem(
      title: 'Lightning Fast Delivery',
      description: 'Get your brand-new apparel and accessories delivered straight to your doorstep with real-time tracking.',
      icon: Icons.local_shipping_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define background gradient colors
    final bgColors = isDark
        ? [const Color(0xFF0F172A), const Color(0xFF071E15)] // Slate to Dark Emerald
        : [const Color(0xFFFFFFFF), const Color(0xFFEBF6F1)]; // White to Light Emerald

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar (Skip Button)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM,
                    vertical: AppConstants.spaceS,
                  ),
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Slider Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Premium Layered 3D Icon Illustration
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Glow Orb
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.08),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.12),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                  .scale(duration: 2000.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), curve: Curves.easeInOutSine),

                              // Outer Rotating Border Ring
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat())
                                  .rotate(duration: 10000.ms),

                              // Inner Glassmorphic Container
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.05) 
                                          : Colors.white.withOpacity(0.7),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.6),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        item.icon,
                                        size: 64,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                                  .move(duration: 1500.ms, begin: const Offset(0, -4), end: const Offset(0, 4), curve: Curves.easeInOutQuad),
                            ],
                          ),
                          const SizedBox(height: 56),

                          // Title
                          Text(
                            item.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fade(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOutQuad),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            item.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fade(duration: 600.ms, delay: 350.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Area (Indicators & Buttons)
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceXL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Opacity(
                      opacity: _currentIndex > 0 ? 1.0 : 0.0,
                      child: TextButton(
                        onPressed: _currentIndex > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: AppConstants.durationNormal,
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Dot Indicators
                    Row(
                      children: List.generate(
                        _items.length,
                        (index) => AnimatedContainer(
                          duration: AppConstants.durationFast,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 6.0,
                          width: _currentIndex == index ? 20.0 : 6.0,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                      ),
                    ),

                    // Next / Start Button
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == _items.length - 1) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: AppConstants.durationNormal,
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentIndex == _items.length - 1 ? 'Start' : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _currentIndex == _items.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
