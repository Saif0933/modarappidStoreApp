import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/quantity_selector.dart';
import '../../../../shared/providers/products_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsPage({super.key, required this.productData});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  int _quantity = 1;
  String _selectedWeight = '';

  @override
  void initState() {
    super.initState();
    _selectedWeight = widget.productData['weight'] ?? '1 kg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = context.isTablet || context.isDesktop;

    final id = widget.productData['id'] as String? ?? '';
    final title = widget.productData['title'] as String? ?? 'Product Details';
    final imageUrl = widget.productData['imageUrl'] as String? ?? '';
    final price = widget.productData['price'] as double? ?? 0.0;
    final originalPrice = widget.productData['originalPrice'] as double?;
    final rating = widget.productData['rating'] as double? ?? 0.0;
    final reviewsCount = widget.productData['reviewsCount'] as int? ?? 0;
    final description = widget.productData['description'] as String? ?? '';
    final category = widget.productData['category'] as String? ?? '';

    // Watch items for cart & wishlist state
    final wishlist = ref.watch(wishlistProvider);
    final allProducts = ref.watch(productsProvider);

    // Filter similar products
    final similarProducts = allProducts
        .where((p) => p.category == category && p.id != id)
        .toList();

    // Map categories for UI weight selector list
    final List<String> weightOptions = [
      _selectedWeight,
      if (_selectedWeight.contains('kg'))
        '2 kg'
      else if (_selectedWeight.contains('g'))
        '1 kg'
      else
        'Standard Pack',
      if (_selectedWeight.contains('kg')) '5 kg' else 'Combo Pack',
    ];

    // Reconstruct Product object for operations
    final product = Product(
      id: id,
      title: title,
      imageUrl: imageUrl,
      price: price,
      originalPrice: originalPrice,
      rating: rating,
      reviewsCount: reviewsCount,
      weight: _selectedWeight,
      description: description,
      category: category,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Action Row
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM,
                    vertical: AppConstants.spaceS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppConstants.lowShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                          onPressed: () => context.pop(),
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),

                      // Title
                      Text(
                        'Product Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Wishlist Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppConstants.lowShadow,
                        ),
                        child: IconButton(
                          icon: Icon(
                            wishlist.contains(id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: wishlist.contains(id)
                                ? Colors.red
                                : AppColors.primary,
                          ),
                          onPressed: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical: AppConstants.spaceS,
                    ),
                    child: isWide
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column: Large Product Image & Quality Highlights
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: [
                                        _buildImageCard(imageUrl, originalPrice, price, isDark, theme, height: 420),
                                        const SizedBox(height: 16),
                                        _buildHighlightsPanel(isDark, theme),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 28),
                                  // Right Column: Details & Immediate Actions in elevated buy-box
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(AppConstants.spaceL),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceDark : Colors.white,
                                        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                                        border: Border.all(
                                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        ),
                                        boxShadow: AppConstants.lowShadow,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildTitleAndPrice(category, title, price, originalPrice, isDark, theme),
                                          const SizedBox(height: 14),
                                          _buildRatingReviews(rating, reviewsCount, isDark, theme),
                                          const SizedBox(height: 20),
                                          _buildWeightSelector(weightOptions, isDark, theme),
                                          const SizedBox(height: 20),
                                          _buildDescription(description, theme),
                                          const SizedBox(height: 20),
                                          _buildQuantityRow(theme),
                                          const SizedBox(height: 28),
                                          _buildActionButtons(product, title, theme),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              _buildSimilarProducts(similarProducts, wishlist, isDark, theme, isWide: true),
                              const SizedBox(height: 32),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageCard(
                                imageUrl,
                                originalPrice,
                                price,
                                isDark,
                                theme,
                                height: (MediaQuery.sizeOf(context).width * 0.72).clamp(250.0, 320.0),
                              ),
                              _buildTitleAndPrice(category, title, price, originalPrice, isDark, theme),
                              const SizedBox(height: 12),
                              _buildRatingReviews(rating, reviewsCount, isDark, theme),
                              const SizedBox(height: 24),
                              _buildWeightSelector(weightOptions, isDark, theme),
                              const SizedBox(height: 24),
                              _buildDescription(description, theme),
                              const SizedBox(height: 24),
                              _buildQuantityRow(theme),
                              const SizedBox(height: 32),
                              _buildSimilarProducts(similarProducts, wishlist, isDark, theme, isWide: false),
                              const SizedBox(height: 32),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // Bottom Add to Cart & Buy Now Buttons Sticky Panel (Phones only)
            if (!isWide)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _buildActionButtons(product, title, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, double? originalPrice, double price, bool isDark, ThemeData theme, {required double height}) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: AppConstants.lowShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                child: NetworkImageWidget(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (originalPrice != null && originalPrice > price)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusM,
                    ),
                  ),
                  child: Text(
                    '${(((originalPrice - price) / originalPrice) * 100).round()}% OFF',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndPrice(String category, String title, double price, double? originalPrice, bool isDark, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (originalPrice != null && originalPrice > price)
              Text(
                '\$${originalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingReviews(double rating, int reviewsCount, bool isDark, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              AppConstants.radiusS,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$reviewsCount reviews',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSelector(List<String> weightOptions, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Weight / Size',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: weightOptions.map((weightOption) {
            final isSelected = _selectedWeight == weightOption;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWeight = weightOption;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.surfaceDark
                            : Colors.white),
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusM,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                  ),
                ),
                child: Text(
                  weightOption,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription(String description, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Description',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Quantity',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        QuantitySelector(
          quantity: _quantity,
          onChanged: (val) {
            setState(() {
              _quantity = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(Product product, String title, ThemeData theme) {
    return Row(
      children: [
        // Add to Cart outlined button
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusM,
                ),
              ),
            ),
            child: Text(
              'Add to Cart',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .addToCart(product, qty: _quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$title ($_quantity items) added to cart!',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Buy Now filled button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusM,
                ),
              ),
            ),
            child: Text(
              'Buy Now',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .addToCart(product, qty: _quantity);
              context.push('/checkout');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsPanel(bool isDark, ThemeData theme) {
    final highlights = [
      {'icon': Icons.local_shipping_outlined, 'title': 'Free Express Delivery', 'desc': 'On all orders above \$49'},
      {'icon': Icons.verified_outlined, 'title': 'Authentic Quality', 'desc': '100% genuine & fresh products'},
      {'icon': Icons.replay_circle_filled_outlined, 'title': '7 Days Easy Returns', 'desc': 'Instant refund or replacement'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppConstants.lowShadow,
      ),
      child: Column(
        children: highlights.map((h) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    h['icon'] as IconData,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        h['desc'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSimilarProducts(List<Product> similarProducts, Set<String> wishlist, bool isDark, ThemeData theme, {required bool isWide}) {
    if (similarProducts.isEmpty) return const SizedBox.shrink();

    final cardWidth = isWide ? 190.0 : 160.0;
    final listHeight = isWide ? 295.0 : 265.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Products',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: similarProducts.length,
            itemBuilder: (context, index) {
              final sp = similarProducts[index];
              return Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.spaceM,
                  bottom: 8.0,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: ProductCard(
                    id: sp.id,
                    title: sp.title,
                    imageUrl: sp.imageUrl,
                    price: sp.price,
                    originalPrice: sp.originalPrice,
                    rating: sp.rating,
                    reviewsCount: sp.reviewsCount,
                    weight: sp.weight,
                    isWishlisted: wishlist.contains(sp.id),
                    onAddToCart: () {
                      ref
                          .read(cartProvider.notifier)
                          .addToCart(sp);
                    },
                    onWishlistTap: () {
                      ref
                          .read(wishlistProvider.notifier)
                          .toggleWishlist(sp.id);
                    },
                    onTap: () {
                      context.pushReplacement(
                        '/product-details',
                        extra: {
                          'id': sp.id,
                          'title': sp.title,
                          'imageUrl': sp.imageUrl,
                          'price': sp.price,
                          'originalPrice': sp.originalPrice,
                          'rating': sp.rating,
                          'reviewsCount': sp.reviewsCount,
                          'weight': sp.weight,
                          'description': sp.description,
                          'category': sp.category,
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
