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

class ShirtColorVariant {
  final String name;
  final String imageUrl;
  final Color color;

  const ShirtColorVariant({
    required this.name,
    required this.imageUrl,
    required this.color,
  });
}

class GridSuggestedProduct {
  final String id;
  final String brand;
  final String title;
  final String imageUrl;
  final double price;
  final double originalPrice;
  final double? rating;
  final String? reviewsCountText;
  final bool isAd;

  const GridSuggestedProduct({
    required this.id,
    required this.brand,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    this.rating,
    this.reviewsCountText,
    this.isAd = false,
  });
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  // Selection states
  int _selectedColorIndex = 1; // Default to Brown as shown in reference image
  String _selectedSize = 'M';
  int _quantity = 1;

  // Accordion expansion states
  bool _isDescriptionExpanded = false;
  bool _isSizeGuideExpanded = false;
  bool _isReviewsExpanded = false;

  // 5 Color variants matching reference image
  late final List<ShirtColorVariant> _colorVariants;

  // PageController for swipeable product banner
  late final PageController _bannerPageController;

  // ScrollController to transition top header on scroll
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  // Size options
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

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
    final brownImage = (passedImage != null && passedImage.isNotEmpty)
        ? passedImage
        : 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800';

    _colorVariants = [
      const ShirtColorVariant(
        name: 'Black',
        imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800',
        color: Color(0xFF18181B),
      ),
      ShirtColorVariant(
        name: 'Brown',
        imageUrl: brownImage,
        color: const Color(0xFF78350F),
      ),
      const ShirtColorVariant(
        name: 'Beige',
        imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=800',
        color: Color(0xFFD4B996),
      ),
      const ShirtColorVariant(
        name: 'Dark Green',
        imageUrl: 'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=800',
        color: Color(0xFF14532D),
      ),
      const ShirtColorVariant(
        name: 'Mustard',
        imageUrl: 'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=800',
        color: Color(0xFFB45309),
      ),
    ];

    _bannerPageController = PageController(initialPage: _selectedColorIndex);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final scrolled = _scrollController.hasClients && _scrollController.offset > 80;
      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerPageController.dispose();
    super.dispose();
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
    final id = widget.productData['id']?.toString() ?? 'p_jackbella_shirt';
    final title = widget.productData['title']?.toString() ??
        'JACKBELLA Men Regular Fit Self Design S...';
    final brand = widget.productData['brand']?.toString() ?? 'JACKBELLA';
    final price = _parseDouble(widget.productData['price'], 287.0);
    final originalPrice = _parseDouble(widget.productData['originalPrice'], 1499.0);
    final rating = _parseDouble(widget.productData['rating'], 3.7);
    final reviewsCount = _parseReviewsCount(widget.productData['reviewsCount'] ?? 3);
    final description = widget.productData['description']?.toString() ??
        'JACKBELLA Men Regular Fit Self Design casual shirt. Crafted from breathable, premium blended cotton fabric with curved hemline and tailored spread collar.';
    final category = widget.productData['category']?.toString() ?? 'Shirts';

    // Discount percentage
    final discountPercent = originalPrice > price
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 81;

    // Watch items for cart & wishlist state
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(id);
    final allProducts = ref.watch(productsProvider);
    final similarProducts = _getSimilarProducts(id, category, allProducts);
    final recentlyViewedProducts = _getRecentlyViewedProducts(id, allProducts);

    final currentVariant = _colorVariants[_selectedColorIndex];

    // Reconstruct Product model for operations
    final product = Product(
      id: id,
      title: title,
      imageUrl: currentVariant.imageUrl,
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
            // 1. Top Header with AD Banner Card (Soft blue accent background from screenshot)
            _buildTopHeader(
              title: title,
              discountPercent: discountPercent,
              price: price,
              originalPrice: originalPrice,
              isWishlisted: isWishlisted,
              productId: id,
            ),

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
                      isWishlisted: isWishlisted,
                      similarProducts: similarProducts,
                      recentlyViewedProducts: recentlyViewedProducts,
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
                      isWishlisted: isWishlisted,
                      similarProducts: similarProducts,
                      recentlyViewedProducts: recentlyViewedProducts,
                    ),
            ),

            // 3. Sticky Bottom Action Bar ("Add to cart" and "Buy now")
            _buildBottomActionBar(product, title),
          ],
        ),
      ),
    );
  }

  // Scrolled Search Top Header matching the screenshot
  Widget _buildScrolledSearchHeader() {
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      color: const Color(0xFFD6EEFD),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        children: [
          // Back Button
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Search Field Pill ("Search for products")
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Search for products',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Shopping Cart with "0" Badge
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/cart'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 24,
                    color: Color(0xFF374151),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Top Header matching the screenshot: pale blue bar with Back Button + AD Card
  Widget _buildTopHeader({
    required String title,
    required int discountPercent,
    required double price,
    required double originalPrice,
    required bool isWishlisted,
    required String productId,
  }) {
    if (_isScrolled) {
      return _buildScrolledSearchHeader();
    }

    return Container(
      color: const Color(0xFFD6EEFD),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        children: [
          // Circular Back Button
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // AD Banner Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Green shirt thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const NetworkImageWidget(
                      imageUrl:
                          'https://images.unsplash.com/photo-1620012253295-c15c429fccf8?w=200',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title and price row
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '↓ $discountPercent%',
                              style: const TextStyle(
                                color: Color(0xFF00875A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${originalPrice.toInt()}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹${price.toInt()}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // AD Badge
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Circular glass-style button
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

  // Mobile layout (< 800px) matching screenshot order
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
    required bool isWishlisted,
    required List<Product> similarProducts,
    required List<Product> recentlyViewedProducts,
  }) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        // 1. Hero Image with Floating Wishlist/Share, Rating Pill & Slider Track
        _buildHeroImage(
          productId: product.id,
          isWishlisted: isWishlisted,
          title: title,
          rating: rating,
          reviewsCount: reviewsCount,
        ),

        // 2. Selected Color Selector with Horizontal Thumbnails
        _buildColorSelector(),
        const SizedBox(height: 22),

        // 3. Size Selector
        _buildSizeSelector(),
        const SizedBox(height: 22),

        // 4. Quantity Stepper
        _buildQuantityStepper(),
        const SizedBox(height: 26),

        // 5. Product Details Header & Paragraph
        _buildProductDetailsHeader(description),
        const SizedBox(height: 18),

        // 6. 4 Feature Badges Grid
        _buildFeatureBadges(),
        const SizedBox(height: 20),

        // 7. Specifications Table Card
        _buildSpecificationsTable(),
        const SizedBox(height: 24),

        // 8. Delivery Information Card
        _buildDeliveryInfoCard(),
        const SizedBox(height: 24),

        // 9. Similar Products Suggestion Section (directly below Delivery Information)
        _buildSimilarProductsSection(similarProducts),
        const SizedBox(height: 24),

        // 10. Expandable Accordions
        _buildAccordions(rating),
        const SizedBox(height: 24),

        // 11. Recently Viewed Products (Vertical Section directly below Reviews)
        _buildRecentlyViewedSection(recentlyViewedProducts),
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
    required bool isWishlisted,
    required List<Product> similarProducts,
    required List<Product> recentlyViewedProducts,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Hero Image, Color Selector, Features, Specs
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeroImage(
                        productId: product.id,
                        isWishlisted: isWishlisted,
                        title: title,
                        rating: rating,
                        reviewsCount: reviewsCount,
                      ),
                      _buildColorSelector(),
                      const SizedBox(height: 24),
                      _buildFeatureBadges(),
                      const SizedBox(height: 24),
                      _buildSpecificationsTable(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 28),

              // Right Column: Title, Price, Selectors, Delivery, Similar Products, Accordions
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
                      _buildSizeSelector(),
                      const SizedBox(height: 22),
                      _buildQuantityStepper(),
                      const SizedBox(height: 26),
                      _buildProductDetailsHeader(description),
                      const SizedBox(height: 20),
                      _buildDeliveryInfoCard(),
                      const SizedBox(height: 24),
                      _buildSimilarProductsSection(similarProducts),
                      const SizedBox(height: 24),
                      _buildAccordions(rating),
                      const SizedBox(height: 24),
                      _buildRecentlyViewedSection(recentlyViewedProducts),
                      const SizedBox(height: 24),
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

  // 1. Hero Image with Floating Wishlist/Share buttons, Rating Chip & Slider Progress Line
  Widget _buildHeroImage({
    required String productId,
    required bool isWishlisted,
    required String title,
    required double rating,
    required int reviewsCount,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            // Swipeable Product Banner Images
            Container(
              width: double.infinity,
              height: 440,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  controller: _bannerPageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _colorVariants.length,
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedColorIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return NetworkImageWidget(
                      imageUrl: _colorVariants[index].imageUrl,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            // Top-Right Floating Action Buttons: Wishlist & Share
            Positioned(
              top: 14,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist Button (Heart with mini plus badge)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(wishlistProvider.notifier).toggleWishlist(productId);
                        },
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isWishlisted ? Colors.red : Colors.black87,
                                size: 22,
                              ),
                              if (!isWishlisted)
                                const Positioned(
                                  top: 10,
                                  right: 9,
                                  child: Icon(
                                    Icons.add,
                                    size: 10,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Share Button (Paper airplane rotated)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _shareProduct(title),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.25,
                            child: const Icon(
                              Icons.send_outlined,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom-Left Floating Rating Pill
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF00875A),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '|',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$reviewsCount',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Carousel Slider Progress Indicator Bar with real-time sliding sync
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          height: 2.5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segWidth = constraints.maxWidth / _colorVariants.length;
              return AnimatedBuilder(
                animation: _bannerPageController,
                builder: (context, _) {
                  final page = _bannerPageController.hasClients &&
                          _bannerPageController.page != null
                      ? _bannerPageController.page!
                      : _selectedColorIndex.toDouble();
                  final leftOffset = (page * segWidth).clamp(
                    0.0,
                    constraints.maxWidth - segWidth,
                  );
                  return Stack(
                    children: [
                      Positioned(
                        left: leftOffset,
                        top: 0,
                        bottom: 0,
                        width: segWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
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

  // 7. Selected Color Variant Selector with Horizontal Thumbnails matching screenshot
  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading: "Selected Color: Brown"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text.rich(
            TextSpan(
              text: 'Selected Color: ',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: _colorVariants[_selectedColorIndex].name,
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Row of Color Variant Thumbnails
        SizedBox(
          height: 98,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _colorVariants.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedColorIndex == index;
              final variant = _colorVariants[index];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedColorIndex = index;
                  });
                  if (_bannerPageController.hasClients) {
                    _bannerPageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 68,
                  height: 94,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (_isDark ? Colors.white : Colors.black)
                          : (_isDark ? AppColors.borderDark : Colors.grey.shade300),
                      width: isSelected ? 2.0 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWidget(
                      imageUrl: variant.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
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

  // Curated & Dynamic Similar Products
  List<Product> _getSimilarProducts(
    String currentId,
    String currentCategory,
    List<Product> allProducts,
  ) {
    final curatedSimilarShirts = [
      const Product(
        id: 'sim_1',
        title: 'JACKBELLA Men Slim Fit Solid Casual Shirt',
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500',
        price: 299.0,
        originalPrice: 1499.0,
        rating: 4.2,
        reviewsCount: 88,
        weight: 'M',
        description: 'Navy blue slim fit cotton shirt with spread collar and curved hem.',
        category: 'Shirts',
      ),
      const Product(
        id: 'sim_2',
        title: 'JACKBELLA Men Regular Fit Textured Shirt',
        imageUrl: 'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=500',
        price: 319.0,
        originalPrice: 1599.0,
        rating: 4.4,
        reviewsCount: 142,
        weight: 'L',
        description: 'Bottle green textured full-sleeve shirt with wooden buttons.',
        category: 'Shirts',
      ),
      const Product(
        id: 'sim_3',
        title: 'URBAN CREW Men Premium Cotton Shirt',
        imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=500',
        price: 349.0,
        originalPrice: 1699.0,
        rating: 4.5,
        reviewsCount: 215,
        weight: 'M',
        description: 'Off-white breathable summer cotton casual shirt.',
        category: 'Shirts',
      ),
      const Product(
        id: 'sim_4',
        title: 'JACKBELLA Men Caramel Tan Casual Shirt',
        imageUrl: 'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=500',
        price: 287.0,
        originalPrice: 1499.0,
        rating: 4.1,
        reviewsCount: 64,
        weight: 'L',
        description: 'Caramel tan regular fit smart casual shirt for men.',
        category: 'Shirts',
      ),
      const Product(
        id: 'sim_5',
        title: 'Blaq Ash Men Formal Solid Black Shirt',
        imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=500',
        price: 369.0,
        originalPrice: 1899.0,
        rating: 4.6,
        reviewsCount: 198,
        weight: 'XL',
        description: 'Deep black crisp formal shirt with anti-wrinkle finish.',
        category: 'Shirts',
      ),
    ];

    final otherProducts = allProducts.where((p) => p.id != currentId).toList();
    return [...curatedSimilarShirts.where((p) => p.id != currentId), ...otherProducts];
  }

  // Similar Products Suggestion Section directly below Delivery Information
  Widget _buildSimilarProductsSection(List<Product> similarProducts) {
    if (similarProducts.isEmpty) return const SizedBox.shrink();

    final wishlist = ref.watch(wishlistProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Similar Products',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customers also frequently viewed',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isDark
                    ? _primaryColor.withValues(alpha: 0.2)
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${similarProducts.length} items',
                style: TextStyle(
                  color: _isDark ? const Color(0xFF6EE7B7) : AppColors.primaryDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal Product Cards Carousel
        SizedBox(
          height: 255,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: similarProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = similarProducts[index];
              final isItemWishlisted = wishlist.contains(item.id);
              final origPrice = item.originalPrice ?? (item.price * 1.6);
              final discount = origPrice > item.price
                  ? (((origPrice - item.price) / origPrice) * 100).round()
                  : 40;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(
                    '/product-details',
                    extra: {
                      'id': item.id,
                      'title': item.title,
                      'imageUrl': item.imageUrl,
                      'price': item.price,
                      'originalPrice': origPrice,
                      'rating': item.rating,
                      'reviewsCount': item.reviewsCount,
                      'weight': item.weight,
                      'description': item.description,
                      'category': item.category,
                    },
                  );
                },
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: _cardBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cardBorderColor, width: 1),
                    boxShadow: _isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image with Wishlist Button & Rating Pill
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                            child: SizedBox(
                              width: 160,
                              height: 145,
                              child: NetworkImageWidget(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Wishlist Toggle Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref.read(wishlistProvider.notifier).toggleWishlist(item.id);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isItemWishlisted
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isItemWishlisted ? Colors.red : Colors.black87,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),

                          // Rating Pill on Image
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFF00875A),
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '₹${item.price.toInt()}',
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${origPrice.toInt()}',
                                  style: TextStyle(
                                    color: _textMuted,
                                    fontSize: 11.5,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$discount% off',
                              style: const TextStyle(
                                color: Color(0xFF00875A),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  // Curated & Dynamic Recently Viewed Products
  List<Product> _getRecentlyViewedProducts(
    String currentId,
    List<Product> allProducts,
  ) {
    return allProducts.where((p) => p.id != currentId).toList();
  }

  // Number formatting helper (e.g. 1499 -> "1,499", 499 -> "499")
  String _formatPriceNoSymbol(double price) {
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final str = intPrice.toString();
      final thousands = str.substring(0, str.length - 3);
      final hundreds = str.substring(str.length - 3);
      return '$thousands,$hundreds';
    }
    return intPrice.toString();
  }

  // Curated 6 Products from the uploaded reference image
  static const List<GridSuggestedProduct> _gridSuggestedProducts = [
    GridSuggestedProduct(
      id: 'himas_1',
      brand: 'HIMAS',
      title: 'Men Regular Fit S...',
      imageUrl:
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600',
      price: 310,
      originalPrice: 499,
      rating: 4.3,
      reviewsCountText: '9',
      isAd: false,
    ),
    GridSuggestedProduct(
      id: 'spoque_2',
      brand: 'SPOQUE',
      title: 'Men Regular Fit ...',
      imageUrl:
          'https://images.unsplash.com/photo-1620012253295-c15c429fccf8?w=600',
      price: 367,
      originalPrice: 1499,
      rating: 4.1,
      reviewsCountText: '4.8K+',
      isAd: true,
    ),
    GridSuggestedProduct(
      id: 'javier_3',
      brand: 'javier',
      title: 'Men Regular Fit Em...',
      imageUrl:
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600',
      price: 285,
      originalPrice: 1299,
      rating: 4.2,
      reviewsCountText: '40',
      isAd: false,
    ),
    GridSuggestedProduct(
      id: 'growwax_4',
      brand: 'Growwax',
      title: 'Men Regular Fi...',
      imageUrl:
          'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=600',
      price: 348,
      originalPrice: 999,
      isAd: false,
    ),
    GridSuggestedProduct(
      id: 'sopani_5',
      brand: 'SOPANI',
      title: 'Men Regular Fit ...',
      imageUrl:
          'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=600',
      price: 299,
      originalPrice: 1199,
      isAd: true,
    ),
    GridSuggestedProduct(
      id: 'varidashi_6',
      brand: 'Varidashi',
      title: 'Men Regular Fi...',
      imageUrl:
          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600',
      price: 329,
      originalPrice: 1399,
      isAd: false,
    ),
  ];

  // 2-Column Product Card strictly matching the screenshot layout
  Widget _buildGridProductCard(GridSuggestedProduct item) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(
          '/product-details',
          extra: {
            'id': item.id,
            'title': '${item.brand} ${item.title}',
            'imageUrl': item.imageUrl,
            'price': item.price,
            'originalPrice': item.originalPrice,
            'rating': item.rating ?? 4.2,
            'reviewsCount': int.tryParse(item.reviewsCountText?.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 50,
            'weight': 'M',
            'description': '${item.brand} Men Regular Fit Casual Shirt. Crafted with soft breathable fabric for all-day comfort.',
            'category': 'Shirts',
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image with Rounded Corners + Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 0.82,
                  child: Container(
                    color: _isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                    child: NetworkImageWidget(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

              // Top-right AD badge (if sponsored)
              if (item.isAd)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),

              // Bottom-left Rating Badge Pill
              if (item.rating != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFF00875A), // Green star from screenshot!
                          size: 13,
                        ),
                        if (item.reviewsCountText != null) ...[
                          Container(
                            height: 10,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.grey.shade300,
                          ),
                          Text(
                            item.reviewsCountText!,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. Brand & Title (HIMAS Men Regular Fit S...)
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: _textPrimary,
              ),
              children: [
                TextSpan(
                  text: '${item.brand} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 3),

          // 3. Price Row (499 ₹310)
          Row(
            children: [
              Text(
                _formatPriceNoSymbol(item.originalPrice),
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 12.5,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '₹${_formatPriceNoSymbol(item.price)}',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Vertical 2-Column Product Grid Section matching the uploaded reference image
  Widget _buildRecentlyViewedSection(List<Product> recentlyViewed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _gridSuggestedProducts.length; i += 2) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column Item
                Expanded(
                  child: _buildGridProductCard(_gridSuggestedProducts[i]),
                ),
                const SizedBox(width: 14),
                // Right Column Item
                Expanded(
                  child: (i + 1 < _gridSuggestedProducts.length)
                      ? _buildGridProductCard(_gridSuggestedProducts[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 15. Sticky Bottom Action Bar ("Add to cart" & "Buy now" matching screenshot)
  Widget _buildBottomActionBar(Product product, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: _isDark ? AppColors.borderDark : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Left Button: "Add to cart" (White with subtle border and rounded pill shape)
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isDark ? AppColors.bgDark : Colors.white,
                    side: BorderSide(
                      color: _isDark ? AppColors.borderDark : Colors.grey.shade300,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(cartProvider.notifier).addToCart(
                          product,
                          qty: _quantity,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added $_quantity x $title (${_colorVariants[_selectedColorIndex].name}, $_selectedSize) to Cart!',
                        ),
                        backgroundColor: const Color(0xFF1F2937),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'View Cart',
                          textColor: const Color(0xFFFFD200),
                          onPressed: () => _safePush('/cart'),
                        ),
                      ),
                    );
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Add to cart',
                      style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Button: "Buy now" (Vivid Yellow #FFD200 with rounded pill shape)
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD200),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(cartProvider.notifier).addToCart(
                          product,
                          qty: _quantity,
                        );
                    _safePush('/checkout');
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Buy now',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
