import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../../../shared/providers/products_provider.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch wishlist and all products
    final wishlistIds = ref.watch(wishlistProvider);
    final allProducts = ref.watch(productsProvider);
    
    // Filter wishlisted products
    final wishlistedProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();

    if (wishlistedProducts.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: EmptyWidget(
          icon: Icons.favorite_border_rounded,
          title: 'Your Wishlist is Empty',
          description: 'Save items you love here to easily purchase them later.',
          buttonText: 'Discover Products',
          onButtonPressed: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          physics: const BouncingScrollPhysics(),
          itemCount: wishlistedProducts.length,
          itemBuilder: (context, index) {
            final product = wishlistedProducts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: AppConstants.lowShadow,
              ),
              child: Row(
                children: [
                  // Image
                  NetworkImageWidget(
                    imageUrl: product.imageUrl,
                    width: 72,
                    height: 72,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),

                  // Details Block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Price
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        
                        // Weight
                        Text(
                          product.weight,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Move to Cart & Remove Action Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Move to Cart Icon button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_rounded, size: 14),
                        label: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ref.read(wishlistProvider.notifier).remove(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Moved ${product.title} to cart.'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Delete Icon button
                      GestureDetector(
                        onTap: () {
                          ref.read(wishlistProvider.notifier).remove(product.id);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Remove',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
