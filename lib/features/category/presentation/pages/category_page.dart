import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Women',
    'Men',
    'Kids',
    'Footwear',
    'Bags',
    'Accessories',
  ];

  final List<Map<String, String>> _categories = [
    {
      'id': 'women',
      'title': 'Women',
      'subtitle': 'Dresses, Tops, Kurtis, Ethnic & More',
      'image': 'assets/images/card_cat_women.png',
    },
    {
      'id': 'men',
      'title': 'Men',
      'subtitle': 'T-Shirts, Shirts, Jeans, Jackets & More',
      'image': 'assets/images/card_cat_men.png',
    },
    {
      'id': 'kids',
      'title': 'Kids',
      'subtitle': 'Clothing, Sets, Frocks, Accessories & More',
      'image': 'assets/images/card_cat_kids.png',
    },
    {
      'id': 'footwear',
      'title': 'Footwear',
      'subtitle': 'Sneakers, Casuals, Sports, Heels & More',
      'image': 'assets/images/card_cat_footwear.png',
    },
    {
      'id': 'bags',
      'title': 'Bags',
      'subtitle': 'Handbags, Backpacks, Sling Bags & More',
      'image': 'assets/images/card_cat_bags.png',
    },
    {
      'id': 'accessories',
      'title': 'Accessories',
      'subtitle': 'Sunglasses, Belts, Jewellery, Watches & More',
      'image': 'assets/images/card_cat_accessories.png',
    },
  ];

  final List<Map<String, String>> _styles = [
    {
      'title': 'Casual',
      'image': 'assets/images/style_casual.png',
    },
    {
      'title': 'Ethnic',
      'image': 'assets/images/style_ethnic.png',
    },
    {
      'title': 'Party Wear',
      'image': 'assets/images/style_party.png',
    },
    {
      'title': 'Western',
      'image': 'assets/images/style_western.png',
    },
    {
      'title': 'Winter Wear',
      'image': 'assets/images/style_winter.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter categories if specific chip is selected
    final displayedCategories = _selectedFilter == 'All'
        ? _categories
        : _categories.where((c) => c['title'] == _selectedFilter).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 1. Top App Bar (ModaRapp Logo, Bell, Cart Badge)
                _buildTopAppBar(context),

                const SizedBox(height: 16),

                // 2. Categories Title & Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF18181B),
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Explore our wide range of fashion categories',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF71717A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Horizontal Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        borderRadius: BorderRadius.circular(19),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE61858)
                                : const Color(0xFFFDF2F4),
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF18181B),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // 4. 2-Column Grid of Main Category Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 10) / 2;

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(displayedCategories.length,
                            (index) {
                          final cat = displayedCategories[index];

                          return SizedBox(
                            width: cardWidth,
                            child: InkWell(
                              onTap: () {
                                context.push('/search', extra: cat['title']);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 220 / 142,
                                  child: Image.asset(
                                    cat['image']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 5. "Shop by Style" Section
                _buildShopByStyle(context),

                const SizedBox(height: 20),

                // 6. "New Collection" Promotional Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => context.push('/search', extra: 'New Collection'),
                    borderRadius: BorderRadius.circular(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 448 / 125,
                        child: Image.asset(
                          'assets/images/banner_new_collection.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Top App Bar (ModaRapp Logo, Bell, Cart Badge)
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand Name
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/modarapp_logo.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF18181B),
                        letterSpacing: -0.3,
                      ),
                      children: [
                        TextSpan(text: 'Moda'),
                        TextSpan(
                          text: 'Rapp',
                          style: TextStyle(
                            color: Color(0xFFE61858),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Fashion Delivered Fast',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF71717A),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Notification Bell & Cart Badge
          Row(
            children: [
              // Notification Bell with Pink Dot
              InkWell(
                onTap: () => context.push('/notifications'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF18181B),
                        size: 26,
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE61858),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Shopping Cart with '3' Badge
              InkWell(
                onTap: () => context.push('/cart'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFF18181B),
                        size: 25,
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE61858),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
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
    );
  }

  // 5. "Shop by Style" Section
  Widget _buildShopByStyle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop by Style',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                ),
              ),
              InkWell(
                onTap: () => context.push('/search', extra: 'Styles'),
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE61858),
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Color(0xFFE61858),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 5 Style Circles distributed across the width
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final circleSize = isNarrow ? 56.0 : 62.0;

              final items = _styles.map((style) {
                return InkWell(
                  onTap: () => context.push('/search', extra: style['title']),
                  borderRadius: BorderRadius.circular(35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            style['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        style['title']!,
                        style: TextStyle(
                          fontSize: isNarrow ? 10.5 : 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              if (isNarrow) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: items
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: item,
                            ))
                        .toList(),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items,
              );
            },
          ),
        ),
      ],
    );
  }
}
