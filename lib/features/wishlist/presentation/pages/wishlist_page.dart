import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  String _selectedFilter = 'All (12)';

  final List<String> _filters = [
    'All (12)',
    'Women (6)',
    'Men (2)',
    'Kids (2)',
    'Footwear (1)',
    'Bags (1)',
  ];

  final List<_WishlistItem> _allItems = [
    _WishlistItem(
      id: 'w1',
      title: 'Women Floral Dress',
      subtitle: 'Trendy Floral Print Dress',
      image: 'assets/images/wishlist_img_1.png',
      discount: '30% OFF',
      price: '₹1,299',
      originalPrice: '₹1,899',
      rating: '4.7',
      reviews: '(1.2K)',
      category: 'Women (6)',
    ),
    _WishlistItem(
      id: 'w2',
      title: 'Men Casual Shirt',
      subtitle: 'Premium Cotton Shirt',
      image: 'assets/images/wishlist_img_2.png',
      discount: '20% OFF',
      price: '₹999',
      originalPrice: '₹1,249',
      rating: '4.5',
      reviews: '(856)',
      category: 'Men (2)',
    ),
    _WishlistItem(
      id: 'w3',
      title: 'Girls Yellow Dress',
      subtitle: 'Comfortable & Stylish',
      image: 'assets/images/wishlist_img_3.png',
      discount: '25% OFF',
      price: '₹899',
      originalPrice: '₹1,199',
      rating: '4.8',
      reviews: '(642)',
      category: 'Kids (2)',
    ),
    _WishlistItem(
      id: 'w4',
      title: 'Women Sneakers',
      subtitle: 'Comfort & Style',
      image: 'assets/images/wishlist_img_4.png',
      discount: '15% OFF',
      price: '₹1,499',
      originalPrice: '₹1,799',
      rating: '4.6',
      reviews: '(980)',
      category: 'Footwear (1)',
    ),
    _WishlistItem(
      id: 'w5',
      title: 'Women Handbag',
      subtitle: 'Trendy Everyday Bag',
      image: 'assets/images/wishlist_img_5.png',
      discount: '20% OFF',
      price: '₹1,799',
      originalPrice: '₹2,299',
      rating: '4.7',
      reviews: '(520)',
      category: 'Bags (1)',
    ),
    _WishlistItem(
      id: 'w6',
      title: 'Stylish Sunglasses',
      subtitle: 'UV Protection',
      image: 'assets/images/wishlist_img_6.png',
      discount: '30% OFF',
      price: '₹699',
      originalPrice: '₹999',
      rating: '4.4',
      reviews: '(310)',
      category: 'Women (6)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayedItems = _selectedFilter == 'All (12)'
        ? _allItems
        : _allItems.where((item) => item.category == _selectedFilter).toList();

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

                // 2. Header Row: "My Wishlist" + "Move All to Cart"
                _buildHeaderRow(context),

                const SizedBox(height: 14),

                // 3. Horizontal Filter Chips
                _buildFilterChips(),

                const SizedBox(height: 16),

                // 4. 2-Column Wishlist Products Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12) / 2;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 14,
                        children: List.generate(displayedItems.length, (index) {
                          final item = displayedItems[index];
                          return SizedBox(
                            width: cardWidth,
                            child: _buildWishlistCard(context, item),
                          );
                        }),
                      );
                    },
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

  // 2. Header Row: "My Wishlist" + "Move All to Cart"
  Widget _buildHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Wishlist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Your saved favorites (12 items)',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          // "Move All to Cart" Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Moving all 12 items to cart...'),
                  backgroundColor: Color(0xFFE61858),
                  duration: Duration(seconds: 1),
                ),
              );
              context.push('/cart');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 14,
                    color: Color(0xFFE61858),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Move All to Cart',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE61858),
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

  // 3. Horizontal Filter Chips
  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE61858)
                    : const Color(0xFFFEEBEF),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF18181B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Individual Wishlist Card
  Widget _buildWishlistCard(BuildContext context, _WishlistItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0F0F3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Top-Rounded Corners
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: AspectRatio(
              aspectRatio: 213 / 110,
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and 3-Dots More Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18181B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _showItemMenu(context, item);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 17,
                          color: Color(0xFF71717A),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Subtitle
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 6),

                // Price Row: Discounted Price + Strikethrough Original
                Row(
                  children: [
                    Text(
                      item.price,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE61858),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.originalPrice,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71717A),
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Rating Row
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item.rating,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      item.reviews,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF71717A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // "Move to Cart" Button
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.title} moved to cart!'),
                          backgroundColor: const Color(0xFFE61858),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE61858),
                        width: 1.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 14,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Move to Cart',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE61858),
                          ),
                        ),
                      ],
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

  void _showItemMenu(BuildContext context, _WishlistItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Color(0xFF18181B)),
              title: const Text('Share Item'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sharing ${item.title}...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFE61858)),
              title: const Text('Remove from Wishlist',
                  style: TextStyle(color: Color(0xFFE61858))),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.title} removed from wishlist'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String discount;
  final String price;
  final String originalPrice;
  final String rating;
  final String reviews;
  final String category;

  _WishlistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.discount,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.category,
  });
}
