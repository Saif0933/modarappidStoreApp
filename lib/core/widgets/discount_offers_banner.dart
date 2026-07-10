import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';

class DiscountOffer {
  final String id;
  final String title;
  final String discountText;
  final String subtitle;
  final String code;
  final String codeDescription;
  final List<Color> gradientColors;
  final IconData icon;

  DiscountOffer({
    required this.id,
    required this.title,
    required this.discountText,
    required this.subtitle,
    required this.code,
    required this.codeDescription,
    required this.gradientColors,
    required this.icon,
  });
}

class DiscountOffersBanner extends StatefulWidget {
  const DiscountOffersBanner({super.key});

  @override
  State<DiscountOffersBanner> createState() => _DiscountOffersBannerState();
}

class _DiscountOffersBannerState extends State<DiscountOffersBanner> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<DiscountOffer> _offers = [
    DiscountOffer(
      id: 'o1',
      title: 'FIRST PURCHASE',
      discountText: '\$15 OFF',
      subtitle: 'Welcome to Modarappid Store!',
      code: 'WELCOME15',
      codeDescription: 'Min. spend \$50 • New users only',
      gradientColors: [const Color(0xFF0E7F53), const Color(0xFF054F33)],
      icon: Icons.shopping_bag_outlined,
    ),
    DiscountOffer(
      id: 'o2',
      title: 'FLASH SALE',
      discountText: '25% OFF',
      subtitle: 'Premium Jackets & Denim',
      code: 'FLASH25',
      codeDescription: 'No min. spend • Ends in 12 hours',
      gradientColors: [const Color(0xFFF97316), const Color(0xFFC2410C)],
      icon: Icons.flash_on_rounded,
    ),
    DiscountOffer(
      id: 'o3',
      title: 'VIP CLUB EXCLUSIVE',
      discountText: '35% OFF',
      subtitle: 'Luxury Bags & Fine Accessories',
      code: 'VIP35',
      codeDescription: 'Min. spend \$120 • Limited stock',
      gradientColors: [const Color(0xFF6366F1), const Color(0xFF3730A3)],
      icon: Icons.workspace_premium_rounded,
    ),
    DiscountOffer(
      id: 'o4',
      title: 'WEEKEND SPECIAL',
      discountText: 'FREE SHIP',
      subtitle: 'Free delivery on all products',
      code: 'FREESHIP',
      codeDescription: 'Min. spend \$30 • Valid till Sunday',
      gradientColors: [const Color(0xFFEC4899), const Color(0xFF9D174D)],
      icon: Icons.local_shipping_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_offers.isEmpty) return;
      if (_currentPage < _offers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: AppConstants.durationNormal,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exclusive Offers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap coupon code to copy & apply',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.local_offer_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceM),

        // Carousel Slider
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  double rotation = 0.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page ?? 0) - index;
                    rotation = value * -0.06; // subtle tilt angle
                    value = (1 - (value.abs() * 0.08)).clamp(0.0, 1.0);
                  }
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..scale(value, value)
                      ..rotateY(rotation),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: OfferCard(offer: offer),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.spaceM),

        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _offers.length,
            (index) => AnimatedContainer(
              duration: AppConstants.durationFast,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 6.0,
              width: _currentPage == index ? 20.0 : 6.0,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OfferCard extends StatefulWidget {
  final DiscountOffer offer;

  const OfferCard({super.key, required this.offer});

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.offer.code));
    setState(() {
      _isCopied = true;
    });

    // Provide sensory feedback
    HapticFeedback.mediumImpact();

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.offer.gradientColors[0].withOpacity(isDark ? 0.2 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.offer.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Premium Background Circles & Ornaments
              Positioned(
                right: -40,
                top: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -40,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.04),
                ),
              ),
              
              // Decorative Sparkles/Star icon on the right
              Positioned(
                right: 32,
                top: 20,
                child: Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),

              // Layout Contents
              Positioned.fill(
                child: InkWell(
                  onTap: _copyToClipboard,
                  splashColor: Colors.white.withOpacity(0.15),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Section (Details + Action Button)
                        Expanded(
                          flex: 65,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Small Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                      ),
                                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                     .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 800.ms),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.offer.title,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Big Discount Text (Flipkart Style)
                              Text(
                                widget.offer.discountText,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                               .shimmer(duration: 2000.ms, color: Colors.white24),

                              // Subtitle
                              Text(
                                widget.offer.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Code Description
                              Text(
                                widget.offer.codeDescription,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Flipkart Style Action Button
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Code: ${widget.offer.code}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: widget.offer.gradientColors[0],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.copy_all_rounded,
                                      size: 13,
                                      color: widget.offer.gradientColors[0],
                                    ),
                                  ],
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                               .shimmer(duration: 1600.ms, color: widget.offer.gradientColors[0].withOpacity(0.15)),
                            ],
                          ),
                        ),

                        // Right Section (Glowing Icon / Image placeholder)
                        Expanded(
                          flex: 35,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glowing background rings
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2000.ms),
                                
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      widget.offer.icon,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Glassmorphic Copy Feedback Animation Overlay
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_isCopied,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    color: _isCopied ? Colors.black.withOpacity(0.4) : Colors.transparent,
                    child: Center(
                      child: AnimatedScale(
                        scale: _isCopied ? 1.0 : 0.7,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        child: AnimatedOpacity(
                          opacity: _isCopied ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceM,
                              vertical: AppConstants.spaceS + 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                              boxShadow: AppConstants.mediumShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: widget.offer.gradientColors[0],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Copied to Clipboard!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
