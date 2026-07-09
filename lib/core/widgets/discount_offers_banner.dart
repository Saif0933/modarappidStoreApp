import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      gradientColors: [
        const Color(0xFF0E7F53),
        const Color(0xFF054F33),
      ],
      icon: Icons.shopping_bag_outlined,
    ),
    DiscountOffer(
      id: 'o2',
      title: 'FLASH SALE',
      discountText: '25% OFF',
      subtitle: 'Premium Jackets & Denim',
      code: 'FLASH25',
      codeDescription: 'No min. spend • Ends in 12 hours',
      gradientColors: [
        const Color(0xFFF97316),
        const Color(0xFFC2410C),
      ],
      icon: Icons.flash_on_rounded,
    ),
    DiscountOffer(
      id: 'o3',
      title: 'VIP CLUB EXCLUSIVE',
      discountText: '35% OFF',
      subtitle: 'Luxury Bags & Fine Accessories',
      code: 'VIP35',
      codeDescription: 'Min. spend \$120 • Limited stock',
      gradientColors: [
        const Color(0xFF6366F1),
        const Color(0xFF3730A3),
      ],
      icon: Icons.workspace_premium_rounded,
    ),
    DiscountOffer(
      id: 'o4',
      title: 'WEEKEND SPECIAL',
      discountText: 'FREE SHIP',
      subtitle: 'Free delivery on all products',
      code: 'FREESHIP',
      codeDescription: 'Min. spend \$30 • Valid till Sunday',
      gradientColors: [
        const Color(0xFFEC4899),
        const Color(0xFF9D174D),
      ],
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
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.05)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
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
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: widget.offer.gradientColors[0].withOpacity(isDark ? 0.15 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(cutoutRadius: 10.0, cutoutPosition: 0.70),
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
                right: -25,
                top: -25,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white.withOpacity(0.06),
                ),
              ),
              Positioned(
                left: 80,
                bottom: -30,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.03),
                ),
              ),
              Positioned(
                right: 90,
                top: 20,
                child: Icon(
                  widget.offer.icon,
                  size: 80,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),

              // Layout Contents
              Row(
                children: [
                  // Left Section (Main Offer Details)
                  Expanded(
                    flex: 70,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Offer Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceS,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 10,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.offer.title,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Discount Text
                          Text(
                            widget.offer.discountText,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.12),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),


                          // Subtitle / Description
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

                          // Extra Info / T&C
                          Text(
                            widget.offer.codeDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider (Dashed vertical line)
                  CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: DashedLinePainter(color: Colors.white.withOpacity(0.35)),
                  ),

                  // Right Section (Ticket Coupon Code Stub)
                  Expanded(
                    flex: 30,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _copyToClipboard,
                        splashColor: Colors.white.withOpacity(0.15),
                        highlightColor: Colors.white.withOpacity(0.08),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.copy_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Text(
                                widget.offer.code,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: widget.offer.gradientColors[0],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'TAP TO COPY',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Glassmorphic Copy Feedback Animation Overlay
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isCopied ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !_isCopied,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceM,
                            vertical: AppConstants.spaceS + 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
            ],
          ),
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double cutoutRadius;
  final double cutoutPosition;

  TicketClipper({required this.cutoutRadius, required this.cutoutPosition});

  @override
  Path getClip(Size size) {
    final path = Path();
    final x = size.width * cutoutPosition;

    path.lineTo(x - cutoutRadius, 0);

    // Top cutout
    path.arcToPoint(
      Offset(x + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(x + cutoutRadius, size.height);

    // Bottom cutout
    path.arcToPoint(
      Offset(x - cutoutRadius, size.height),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 8;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    while (startY < size.height - 8) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
