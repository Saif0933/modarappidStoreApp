import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        body: Center(
          child: EmptyWidget(
            icon: Icons.favorite_border_rounded,
            title: 'Your Wishlist is Empty',
            description: 'Save items you love here to easily purchase them later.',
            buttonText: 'Discover Products',
            onButtonPressed: () => context.go('/home'),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
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
            return Dismissible(
              key: Key(product.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24.0),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              onDismissed: (direction) {
                HapticFeedback.mediumImpact();
                ref.read(wishlistProvider.notifier).remove(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.title} removed from wishlist.'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
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
                    // Image with Rating Badge
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.bgDark : AppColors.bgLight,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: NetworkImageWidget(
                            imageUrl: product.imageUrl,
                            width: 76,
                            height: 76,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // Price & Original Price
                          Row(
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 15,
                                ),
                              ),
                              if (product.originalPrice != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Weight
                          Text(
                            'Size/Qty: ${product.weight}',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Move to Cart & Remove Action Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Move to Cart Icon button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Add to Cart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Delete Icon button
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(wishlistProvider.notifier).remove(product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed ${product.title} from wishlist.'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_outline_rounded, size: 13, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(
                                  'Remove',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate()
             .fadeIn(duration: 450.ms, delay: (index * 60).ms)
             .slideX(begin: 0.25, end: 0, curve: Curves.easeOutBack)
             .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack)
             .blur(begin: const Offset(4, 4), end: Offset.zero);
          },
        ),
      ),
    );
  }
}
