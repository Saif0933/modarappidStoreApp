import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/banner_slider.dart';
import '../../../../core/widgets/category_card.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../shared/providers/products_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch states
    final products = ref.watch(productsProvider);
    final wishlist = ref.watch(wishlistProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    // Filtered products
    final popularProducts = products.where((p) => p.isPopular).toList();
    final recommendedProducts = products.where((p) => p.isRecommended).toList();
    final trendingProducts = products.where((p) => p.isTrending).toList();
    final recentlyViewed = products.sublist(0, 3); // Mock recently viewed

    // Mock Banner URLs (Fashion)
    final List<String> bannerUrls = [
      'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
    ];

    // Categories List (Fashion)
    final List<Map<String, String>> categories = [
      {'title': 'Jackets', 'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=100'},
      {'title': 'Hoodies', 'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=100'},
      {'title': 'Jeans', 'image': 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=100'},
      {'title': 'Footwear', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100'},
      {'title': 'Dresses', 'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=100'},
      {'title': 'Accessories', 'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=100'},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom App Bar / Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting & Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          'Saif Al-Islam 👋',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Location Picker Link
                        GestureDetector(
                          onTap: () => context.push('/address-list'),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                selectedAddress?.addressLine ?? 'Select location',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Notification Icon
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppConstants.lowShadow,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: CustomSearchBar(
                  readOnly: true,
                  onTap: () => context.push('/search'),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // 3. Carousel Banners
              BannerSlider(imageUrls: bannerUrls),
              const SizedBox(height: AppConstants.spaceL),

              // 4. Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/categories'),
                      child: const Text('View All', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),
              SizedBox(
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: CategoryCard(
                        title: cat['title']!,
                        imagePath: cat['image']!,
                        onTap: () => context.go('/categories'), // Takes to category list
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // 5. Popular Products (Horizontal Slider)
              _buildProductSection(
                context: context,
                ref: ref,
                title: 'Popular Products',
                productList: popularProducts,
                wishlist: wishlist,
              ),

              // 6. Recommended Products (Horizontal Slider)
              _buildProductSection(
                context: context,
                ref: ref,
                title: 'Recommended For You',
                productList: recommendedProducts,
                wishlist: wishlist,
              ),

              // 7. Trending Products (Horizontal Slider)
              _buildProductSection(
                context: context,
                ref: ref,
                title: 'Trending Right Now',
                productList: trendingProducts,
                wishlist: wishlist,
              ),

              // 8. Recently Viewed (Horizontal Slider)
              _buildProductSection(
                context: context,
                ref: ref,
                title: 'Recently Viewed',
                productList: recentlyViewed,
                wishlist: wishlist,
              ),
              
              const SizedBox(height: AppConstants.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<Product> productList,
    required Set<String> wishlist,
  }) {
    final theme = Theme.of(context);
    if (productList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM, vertical: AppConstants.spaceS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.primary),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
            physics: const BouncingScrollPhysics(),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spaceM, bottom: 8.0, top: 4.0),
                child: SizedBox(
                  width: 160,
                  child: ProductCard(
                    id: product.id,
                    title: product.title,
                    imageUrl: product.imageUrl,
                    price: product.price,
                    originalPrice: product.originalPrice,
                    rating: product.rating,
                    reviewsCount: product.reviewsCount,
                    weight: product.weight,
                    isWishlisted: wishlist.contains(product.id),
                    onTap: () => context.push('/product-details', extra: {
                      'id': product.id,
                      'title': product.title,
                      'imageUrl': product.imageUrl,
                      'price': product.price,
                      'originalPrice': product.originalPrice,
                      'rating': product.rating,
                      'reviewsCount': product.reviewsCount,
                      'weight': product.weight,
                      'description': product.description,
                      'category': product.category,
                    }),
                    onAddToCart: () {
                      ref.read(cartProvider.notifier).addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} added to cart!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onWishlistTap: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.spaceL),
      ],
    );
  }
}
