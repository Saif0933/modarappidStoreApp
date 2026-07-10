import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
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
            Padding(
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Image Display
                    Center(
                      child: Container(
                        height: 280,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppConstants.spaceM,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXL,
                          ),
                          boxShadow: AppConstants.lowShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXL,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppConstants.spaceL,
                                  ),
                                  child: NetworkImageWidget(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Discount badge
                              if (originalPrice != null &&
                                  originalPrice > price)
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
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Price & Rating Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Price Block
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
                    ),
                    const SizedBox(height: 12),

                    // Rating & Reviews row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
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
                    ),
                    const SizedBox(height: 24),

                    // Weight Size Selector
                    Text(
                      'Select Weight / Size',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: weightOptions.map((weightOption) {
                        final isSelected = _selectedWeight == weightOption;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
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
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Product Description
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
                    const SizedBox(height: 24),

                    // Quantity selector block
                    Row(
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
                    ),
                    const SizedBox(height: 32),

                    // Similar Products drawer / slider
                    if (similarProducts.isNotEmpty) ...[
                      Text(
                        'Similar Products',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 240,
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
                                width: 150,
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Add to Cart & Buy Now Buttons Sticky Panel
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
