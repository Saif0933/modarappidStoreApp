import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/banner_slider.dart';
import '../../../../core/widgets/category_card.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/discount_offers_banner.dart';
import '../../../../core/widgets/feed_product_card.dart';
import '../../../../core/widgets/suggested_product_card.dart';
import '../../../../shared/providers/products_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset != _scrollOffset) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch states
    final products = ref.watch(productsProvider);
    final wishlist = ref.watch(wishlistProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    // Filtered products
    final suggestedProducts = products.take(6).toList();
    final feedProducts = products.where((p) => p.id.startsWith('feed_')).toList();

    // Mock Banner URLs (Fashion)
    final List<String> bannerUrls = [
      'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
    ];

    // Categories List (Fashion)
    final List<Map<String, String>> categories = [
      {
        'title': 'Jackets',
        'image':
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=100',
      },
      {
        'title': 'Hoodies',
        'image':
            'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=100',
      },
      {
        'title': 'Jeans',
        'image':
            'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=100',
      },
      {
        'title': 'Footwear',
        'image':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100',
      },
      {
        'title': 'Dresses',
        'image':
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=100',
      },
      {
        'title': 'Accessories',
        'image':
            'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=100',
      },
    ];

    // Sticky visibility flags
    final bool showStickySearch = _scrollOffset > 100;
    final bool showStickyCategories = _scrollOffset > 520;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Scrollable Main Content
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Greeting & Custom App Bar
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
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
                            GestureDetector(
                              onTap: () => context.push('/address-list'),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: Color.fromARGB(255, 71, 22, 249),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedAddress?.addressLine ??
                                        'Select location',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
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
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: () => context.push('/notifications'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Original Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                    ),
                    child: CustomSearchBar(
                      readOnly: true,
                      onTap: () => context.push('/search'),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceL),

                  // Carousel Banners
                  BannerSlider(imageUrls: bannerUrls),
                  const SizedBox(height: AppConstants.spaceL),

                  // Discount Offers Section
                  const DiscountOffersBanner(),
                  const SizedBox(height: AppConstants.spaceL),

                  // Original Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/categories'),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                  SizedBox(
                    height: 104,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: CategoryCard(
                            title: cat['title']!,
                            imagePath: cat['image']!,
                            onTap: () => context.go('/categories'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceL),

                  // Suggested For You (3-Column Grid matching screenshot!)
                  _buildSuggestedGridSection(
                    context: context,
                    ref: ref,
                    title: 'Suggested For You',
                    productList: suggestedProducts,
                    wishlist: wishlist,
                  ),

                  // 2-Column Product Feed matching screenshot (Jammy & Kammo, VELLOSTA, aadi, Apple Macbook Neo)
                  _buildFeedGridSection(
                    context: context,
                    productList: feedProducts.isNotEmpty
                        ? feedProducts
                        : products.take(6).toList(),
                  ),

                  const SizedBox(height: AppConstants.spaceXXL),
                ],
              ),
            ),
          ),
        ),

        // 2. Sticky Search Bar Overlay
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: showStickySearch ? 0 : -80,
          left: 0,
          right: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDark : AppColors.bgLight,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: 10,
                ),
                child: CustomSearchBar(
                  readOnly: true,
                  onTap: () => context.push('/search'),
                ),
              ),
            ),
          ),
        ),

        // 3. Sticky Categories Chip List Overlay
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: showStickyCategories ? 70 : -140,
          left: 0,
          right: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDark : AppColors.bgLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(bottom: 10, top: 4),
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(
                            cat['title']!,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: isDark
                              ? AppColors.surfaceDark
                              : Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : Colors.grey.shade200,
                            ),
                          ),
                          onPressed: () => context.go('/categories'),
                        ),
                      );
                    },
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

  Widget _buildSuggestedGridSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<Product> productList,
    required Set<String> wishlist,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (productList.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final int cols;
    final double childAspectRatio;

    if (width < 600) {
      // Phone: 3 columns matching screenshot!
      cols = 3;
      childAspectRatio = 0.54;
    } else if (width < 900) {
      // Tablet Portrait: 4 columns
      cols = 4;
      childAspectRatio = 0.62;
    } else {
      // Tablet Landscape / Desktop: 6 columns
      cols = 6;
      childAspectRatio = 0.65;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/categories'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : const Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productList.length.clamp(0, cols * 2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final product = productList[index];
              return SuggestedProductCard(
                id: product.id,
                title: product.title,
                imageUrl: product.imageUrl,
                price: product.price,
                originalPrice: product.originalPrice,
                bankOfferPrice: product.bankOfferPrice,
                onTap: () => context.push(
                  '/product-details',
                  extra: {
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
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.spaceL),
      ],
    );
  }

  Widget _buildFeedGridSection({
    required BuildContext context,
    required List<Product> productList,
  }) {
    if (productList.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final int cols;
    final double childAspectRatio;

    if (width < 600) {
      // Phone: 2 columns matching screenshot
      cols = 2;
      childAspectRatio = 0.58;
    } else if (width < 900) {
      // Tablet Portrait: 3 columns
      cols = 3;
      childAspectRatio = 0.65;
    } else {
      // Tablet Landscape / Desktop: 4 columns
      cols = 4;
      childAspectRatio = 0.70;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: width < 600 ? 10 : 16,
              mainAxisSpacing: width < 600 ? 14 : 20,
            ),
            itemBuilder: (context, index) {
              final product = productList[index];
              return FeedProductCard(
                id: product.id,
                brand: product.brand,
                title: product.title,
                imageUrl: product.imageUrl,
                price: product.price,
                originalPrice: product.originalPrice,
                bankOfferPrice: product.bankOfferPrice,
                rating: product.rating,
                reviewsCount: product.reviewsCount,
                badgeText: product.badgeText,
                showRatingPill: product.id == 'feed_p4' || product.bankOfferPrice != null,
                hasGreyBackground: product.id == 'feed_p2' || product.id == 'feed_p4',
                onTap: () => context.push(
                  '/product-details',
                  extra: {
                    'id': product.id,
                    'title': product.title,
                    'brand': product.brand,
                    'imageUrl': product.imageUrl,
                    'price': product.price,
                    'originalPrice': product.originalPrice,
                    'bankOfferPrice': product.bankOfferPrice,
                    'rating': product.rating,
                    'reviewsCount': product.reviewsCount,
                    'weight': product.weight,
                    'description': product.description,
                    'category': product.category,
                  },
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
