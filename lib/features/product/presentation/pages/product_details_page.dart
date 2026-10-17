import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../../../shared/providers/products_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsPage({super.key, required this.productData});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  // Selection states
  int _selectedImageIndex = 0;
  int _selectedColorIndex = 0;
  String _selectedSize = 'M';
  int _quantity = 1;

  // Accordion expansion states
  bool _isDescriptionExpanded = false;
  bool _isSizeGuideExpanded = false;
  bool _isReviewsExpanded = false;

  // Curated color options
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Purple', 'color': const Color(0xFF6B21A8)},
    {'name': 'White', 'color': const Color(0xFFF8FAFC)},
    {'name': 'Black', 'color': const Color(0xFF18181B)},
    {'name': 'Navy Blue', 'color': const Color(0xFF1E3A8A)},
    {'name': 'Forest Green', 'color': const Color(0xFF166534)},
    {'name': 'Beige', 'color': const Color(0xFFD4B996)},
  ];

  // Size options
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  // Default gallery images for fashion shirts
  late final List<String> _galleryImages;

  // Dynamic Theme Helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.bgDark : AppColors.bgLight;
  Color get _cardBgColor => _isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get _cardBorderColor => _isDark ? AppColors.borderDark : AppColors.borderLight;
  Color get _textPrimary => _isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get _textSecondary => _isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get _textMuted => _isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
  Color get _dividerColor => _isDark ? AppColors.borderDark : AppColors.borderLight;
  Color get _primaryColor => AppColors.primary;

  @override
  void initState() {
    super.initState();
    final passedImage = widget.productData['imageUrl'] as String?;
    _galleryImages = [
      if (passedImage != null && passedImage.isNotEmpty) passedImage,
      'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800', // Front shot
      'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800', // Back shot
      'https://images.unsplash.com/photo-1620012253295-c15c429fccf8?w=800', // Collar close-up
      'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=800', // Fabric texture
      'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=800', // Side model
    ];

    if (_galleryImages.length > 5) {
      _galleryImages.removeRange(5, _galleryImages.length);
    }
  }

  void _copyCouponCode() {
    HapticFeedback.lightImpact();
    Clipboard.setData(const ClipboardData(text: 'FASHION10'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon code "FASHION10" copied! 10% extra off.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareProduct(String title) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link for "$title" copied to clipboard!'),
        backgroundColor: _isDark ? AppColors.surfaceDark : AppColors.textPrimaryLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _safePush(String route) {
    try {
      context.push(route);
    } catch (_) {}
  }

  double _parseDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _parseReviewsCount(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      if (value.toLowerCase().contains('k')) {
        final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
        final numPart = double.tryParse(cleaned) ?? 1.2;
        return (numPart * 1000).toInt();
      }
      return int.tryParse(value) ?? 1200;
    }
    return 1200;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.screenWidth >= 800;

    // Extract product details with fallbacks matching reference image
    final id = widget.productData['id']?.toString() ?? 'p_urban_shirt';
    final title = widget.productData['title']?.toString() ?? "Men's Premium Cotton Casual Shirt";
    final brand = widget.productData['brand']?.toString() ?? 'URBAN CREW';
    final price = _parseDouble(widget.productData['price'], 1199.0);
    final originalPrice = _parseDouble(widget.productData['originalPrice'], 1999.0);
    final rating = _parseDouble(widget.productData['rating'], 4.5);
    final reviewsCount = _parseReviewsCount(widget.productData['reviewsCount']);
    final description = widget.productData['description']?.toString() ??
        'Upgrade your wardrobe with this stylish and comfortable casual shirt. Made from premium cotton fabric, it offers a perfect blend of style and comfort for everyday wear.';
    final category = widget.productData['category']?.toString() ?? 'Shirts';

    // Discount percentage
    final discountPercent = originalPrice > price
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 40;

    // Watch items for cart & wishlist state
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(id);
    final cartList = ref.watch(cartProvider);

    // Reconstruct Product model for operations
    final product = Product(
      id: id,
      title: title,
      imageUrl: _galleryImages[_selectedImageIndex],
      price: price,
      originalPrice: originalPrice,
      rating: rating,
      reviewsCount: reviewsCount,
      weight: _selectedSize,
      description: description,
      category: category,
    );

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Custom App Bar
            _buildTopAppBar(id, isWishlisted, cartList.length, title),

            // 2. Main Scrollable Content
            Expanded(
              child: isTablet
                  ? _buildTabletLayout(
                      product: product,
                      brand: brand,
                      title: title,
                      price: price,
                      originalPrice: originalPrice,
                      discountPercent: discountPercent,
                      rating: rating,
                      reviewsCount: reviewsCount,
                      description: description,
                    )
                  : _buildMobileLayout(
                      product: product,
                      brand: brand,
                      title: title,
                      price: price,
                      originalPrice: originalPrice,
                      discountPercent: discountPercent,
                      rating: rating,
                      reviewsCount: reviewsCount,
                      description: description,
                    ),
            ),

            // 3. Sticky Bottom Action Bar
            _buildBottomActionBar(product, title),
          ],
        ),
      ),
    );
  }

  // Top App Bar with back, wishlist heart, and cart bag counter
  Widget _buildTopAppBar(String productId, bool isWishlisted, int cartCount, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          _buildCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),

          // Actions: Wishlist + Cart with Badge
          Row(
            children: [
              // Wishlist Heart Button
              _buildCircleButton(
                icon: isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: isWishlisted ? AppColors.error : _textPrimary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(wishlistProvider.notifier).toggleWishlist(productId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isWishlisted ? 'Removed from wishlist' : 'Added to wishlist',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),

              // Cart Button with Red Notification Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildCircleButton(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: _textPrimary,
                    onTap: () => _safePush('/cart'),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Center(
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Circular glass-style button used in top bar and share
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    double size = 44,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _cardBgColor,
        shape: BoxShape.circle,
        border: Border.all(color: _cardBorderColor, width: 1),
        boxShadow: _isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: iconColor ?? _textPrimary, size: 20),
          ),
        ),
      ),
    );
  }

  // Mobile layout (< 800px)
  Widget _buildMobileLayout({
    required Product product,
    required String brand,
    required String title,
    required double price,
    required double originalPrice,
    required int discountPercent,
    required double rating,
    required int reviewsCount,
    required String description,
  }) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        // 1. Hero Image with Discount Tag
        _buildHeroImage(discountPercent),
        const SizedBox(height: 14),

        // 2. Thumbnail Carousel Gallery
        _buildThumbnailGallery(),
        const SizedBox(height: 20),

        // 3. Brand, Title & Share Button
        _buildBrandTitleShare(brand, title),
        const SizedBox(height: 10),

        // 4. Rating & Reviews
        _buildRatingReviews(rating, reviewsCount),
        const SizedBox(height: 16),

        // 5. Price Section
        _buildPriceSection(price, originalPrice, discountPercent),
        const SizedBox(height: 18),

        // 6. Extra 10% Off Coupon Banner
        _buildCouponBanner(),
        const SizedBox(height: 22),

        // 7. Color Selector
        _buildColorSelector(),
        const SizedBox(height: 22),

        // 8. Size Selector
        _buildSizeSelector(),
        const SizedBox(height: 22),

        // 9. Quantity Stepper
        _buildQuantityStepper(),
        const SizedBox(height: 30),

        // 10. Product Details Header & Paragraph
        _buildProductDetailsHeader(description),
        const SizedBox(height: 18),

        // 11. 4 Feature Badges Grid
        _buildFeatureBadges(),
        const SizedBox(height: 20),

        // 12. Specifications Table Card
        _buildSpecificationsTable(),
        const SizedBox(height: 26),

        // 13. Delivery Information Card
        _buildDeliveryInfoCard(),
        const SizedBox(height: 22),

        // 14. Expandable Accordions
        _buildAccordions(rating),
        const SizedBox(height: 24),
      ],
    );
  }

  // Tablet layout (>= 800px)
  Widget _buildTabletLayout({
    required Product product,
    required String brand,
    required String title,
    required double price,
    required double originalPrice,
    required int discountPercent,
    required double rating,
    required int reviewsCount,
    required String description,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Hero Image, Gallery, Feature Badges
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeroImage(discountPercent),
                      const SizedBox(height: 14),
                      _buildThumbnailGallery(),
                      const SizedBox(height: 24),
                      _buildFeatureBadges(),
                      const SizedBox(height: 24),
                      _buildSpecificationsTable(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 28),

              // Right Column: Title, Price, Selectors, Delivery, Accordions
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandTitleShare(brand, title),
                      const SizedBox(height: 10),
                      _buildRatingReviews(rating, reviewsCount),
                      const SizedBox(height: 16),
                      _buildPriceSection(price, originalPrice, discountPercent),
                      const SizedBox(height: 18),
                      _buildCouponBanner(),
                      const SizedBox(height: 22),
                      _buildColorSelector(),
                      const SizedBox(height: 22),
                      _buildSizeSelector(),
                      const SizedBox(height: 22),
                      _buildQuantityStepper(),
                      const SizedBox(height: 26),
                      _buildProductDetailsHeader(description),
                      const SizedBox(height: 20),
                      _buildDeliveryInfoCard(),
                      const SizedBox(height: 22),
                      _buildAccordions(rating),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Hero Image with -40% Badge
  Widget _buildHeroImage(int discountPercent) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 380,
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _cardBorderColor, width: 1),
            boxShadow: _isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NetworkImageWidget(
              imageUrl: _galleryImages[_selectedImageIndex],
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Discount Pill Badge (-40%)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isDark
                  ? _primaryColor.withValues(alpha: 0.22)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '-$discountPercent%',
              style: TextStyle(
                color: _isDark ? const Color(0xFF6EE7B7) : AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Thumbnail Carousel Gallery
  Widget _buildThumbnailGallery() {
    return SizedBox(
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_galleryImages.length, (index) {
          final isSelected = _selectedImageIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedImageIndex = index;
                });
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: index < _galleryImages.length - 1 ? 8.0 : 0.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _primaryColor : _cardBorderColor,
                    width: isSelected ? 2.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetworkImageWidget(
                    imageUrl: _galleryImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 3. Brand, Title & Share Button
  Widget _buildBrandTitleShare(String brand, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand.toUpperCase(),
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildCircleButton(
          icon: Icons.share_outlined,
          onTap: () => _shareProduct(title),
          size: 42,
        ),
      ],
    );
  }

  // 4. Rating & Reviews
  Widget _buildRatingReviews(double rating, int reviewsCount) {
    final formattedReviews = reviewsCount >= 1000
        ? '${(reviewsCount / 1000).toStringAsFixed(1)}K'
        : '$reviewsCount';

    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 19),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($formattedReviews reviews)',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // 5. Price Section
  Widget _buildPriceSection(double price, double originalPrice, int discountPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            // Current Price
            Text(
              '₹${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),

            // Strikethrough Original Price
            if (originalPrice > price)
              Text(
                '₹${originalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: _textMuted,
                ),
              ),

            // Discount Badge (40% OFF)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$discountPercent% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Inclusive of all taxes',
          style: TextStyle(
            color: _textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // 6. Extra 10% Off Coupon Banner
  Widget _buildCouponBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _copyCouponCode,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isDark
                ? AppColors.surfaceDark
                : AppColors.primaryLight.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDark
                  ? AppColors.borderDark
                  : AppColors.primary.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Emerald green discount tag icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.local_offer_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),

              // Coupon Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get extra 10% off',
                      style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use code FASHION10',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron Right
              Icon(
                Icons.chevron_right_rounded,
                color: _textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7. Color Selector
  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Color: ',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: _colors[_selectedColorIndex]['name'] as String,
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: List.generate(_colors.length, (index) {
            final isSelected = _selectedColorIndex == index;
            final color = _colors[index]['color'] as Color;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedColorIndex = index;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _primaryColor : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color == const Color(0xFF18181B)
                          ? _cardBorderColor
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 8. Size Selector
  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Size: ',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: _selectedSize,
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                width: 52,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _primaryColor.withValues(alpha: 0.15)
                      : _cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _primaryColor : _cardBorderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? _primaryColor : _textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 9. Quantity Stepper
  Widget _buildQuantityStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 130,
          height: 44,
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _cardBorderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Minus button
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                color: _quantity > 1 ? _textPrimary : _textMuted,
                onPressed: _quantity > 1
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _quantity--;
                        });
                      }
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),

              // Quantity Text
              Text(
                '$_quantity',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              // Plus button
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                color: _textPrimary,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _quantity++;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 10. Product Details Header & Paragraph
  Widget _buildProductDetailsHeader(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // 11. 4 Feature Badges Grid (Premium Cotton, Breathable, Skin Friendly, Perfect Fit)
  Widget _buildFeatureBadges() {
    final features = [
      {'icon': Icons.spa_outlined, 'title': 'Premium\nCotton'},
      {'icon': Icons.air_rounded, 'title': 'Breathable\nFabric'},
      {'icon': Icons.health_and_safety_outlined, 'title': 'Skin\nFriendly'},
      {'icon': Icons.checkroom_rounded, 'title': 'Perfect\nFit'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: features.map((feature) {
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppColors.surfaceDark
                      : AppColors.primaryLight.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isDark
                        ? AppColors.borderDark
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    feature['icon'] as IconData,
                    color: _primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feature['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 12. Specifications Table Card (Material, Fit, Sleeve, Pattern, Neck)
  Widget _buildSpecificationsTable() {
    final specs = [
      {'label': 'Material', 'value': '100% Cotton'},
      {'label': 'Fit', 'value': 'Regular Fit'},
      {'label': 'Sleeve', 'value': 'Full Sleeve'},
      {'label': 'Pattern', 'value': 'Solid'},
      {'label': 'Neck', 'value': 'Spread Collar'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorderColor, width: 1),
      ),
      child: Column(
        children: List.generate(specs.length, (index) {
          final item = specs[index];
          final isLast = index == specs.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          item['value']!,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: _textMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: _dividerColor,
                ),
            ],
          );
        }),
      ),
    );
  }

  // 13. Delivery Information Card
  Widget _buildDeliveryInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cardBorderColor, width: 1),
          ),
          child: Column(
            children: [
              // 1. Free Delivery
              _buildDeliveryInfoRow(
                icon: Icons.local_shipping_outlined,
                title: 'Free delivery',
                subtitle: 'On orders above ₹499',
              ),
              Divider(height: 1, thickness: 1, color: _dividerColor),

              // 2. Delivery By Date
              _buildDeliveryInfoRow(
                icon: Icons.inventory_2_outlined,
                title: 'Delivery by',
                subtitle: '30 - 35 min',
              ),
              Divider(height: 1, thickness: 1, color: _dividerColor),

              // 3. 7 Days Easy Return
              _buildDeliveryInfoRow(
                icon: Icons.replay_circle_filled_outlined,
                title: '7 days easy return',
                subtitle: 'Hassle free returns',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isDark
                  ? AppColors.borderDark.withValues(alpha: 0.5)
                  : AppColors.primaryLight.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDark
                    ? AppColors.borderDark
                    : AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: _textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  // 14. Expandable Accordions (Product Description, Size Guide, Reviews)
  Widget _buildAccordions(double rating) {
    return Column(
      children: [
        // Product Description Accordion
        _buildAccordionItem(
          title: 'Product Description',
          isExpanded: _isDescriptionExpanded,
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Crafted from 100% long-staple combed cotton, this shirt offers an exquisite hand-feel, supreme breathability, and exceptional color fastness. Features durable pearl-finish buttons, a structured spread collar, and reinforced seams.',
              style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Size Guide Accordion
        _buildAccordionItem(
          title: 'Size Guide',
          isExpanded: _isSizeGuideExpanded,
          onTap: () {
            setState(() {
              _isSizeGuideExpanded = !_isSizeGuideExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              children: [
                _buildSizeGuideRow('Size', 'Chest (in)', 'Length (in)', isHeader: true),
                Divider(height: 1, color: _dividerColor),
                _buildSizeGuideRow('S', '38', '28'),
                _buildSizeGuideRow('M', '40', '29'),
                _buildSizeGuideRow('L', '42', '30'),
                _buildSizeGuideRow('XL', '44', '31'),
                _buildSizeGuideRow('XXL', '46', '32'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Reviews Accordion
        _buildAccordionItem(
          title: 'Reviews (1.2K)',
          trailingExtra: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          isExpanded: _isReviewsExpanded,
          onTap: () {
            setState(() {
              _isReviewsExpanded = !_isReviewsExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerReview(
                  'Aarav Sharma',
                  '5.0',
                  'Excellent fabric quality and fits like a dream! Exactly as shown in the picture.',
                ),
                const SizedBox(height: 10),
                _buildCustomerReview(
                  'Rohan Verma',
                  '4.5',
                  'Very comfortable for all-day wear. The material is rich, breathable and durable.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionItem({
    required String title,
    Widget? trailingExtra,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorderColor, width: 1),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?trailingExtra,
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: _textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }

  Widget _buildSizeGuideRow(String size, String chest, String length, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              size,
              style: TextStyle(
                color: isHeader ? _primaryColor : _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              chest,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHeader ? _primaryColor : _textSecondary,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              length,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isHeader ? _primaryColor : _textSecondary,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReview(String name, String stars, String comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark
            ? AppColors.bgDark.withValues(alpha: 0.6)
            : AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark
              ? AppColors.borderDark.withValues(alpha: 0.4)
              : AppColors.primaryLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                  const SizedBox(width: 2),
                  Text(
                    stars,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // 15. Sticky Bottom Action Bar (Buy Now & Add to Cart)
  Widget _buildBottomActionBar(Product product, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(color: _cardBorderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // "Buy Now" themed pill button
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isDark ? AppColors.bgDark : Colors.white,
                  side: BorderSide(color: _cardBorderColor, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(cartProvider.notifier).addToCart(product, qty: _quantity);
                  _safePush('/checkout');
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Buy Now',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // "Add to Cart" vibrant primary emerald pill button
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  elevation: 4,
                  shadowColor: _primaryColor.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(cartProvider.notifier).addToCart(product, qty: _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added $_quantity x $title ($_selectedSize) to Cart!',
                      ),
                      backgroundColor: _primaryColor,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () => _safePush('/cart'),
                      ),
                    ),
                  );
                },
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
