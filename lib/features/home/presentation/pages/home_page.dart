import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/products_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Deal timer countdown: 06h 24m 18s
  int _secondsRemaining = 6 * 3600 + 24 * 60 + 18;
  Timer? _dealTimer;


  @override
  void initState() {
    super.initState();
    _startDealTimer();
  }

  void _startDealTimer() {
    _dealTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() => _secondsRemaining--);
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _dealTimer?.cancel();
    super.dispose();
  }

  String get _hours {
    final h = _secondsRemaining ~/ 3600;
    return h.toString().padLeft(2, '0');
  }

  String get _minutes {
    final m = (_secondsRemaining % 3600) ~/ 60;
    return m.toString().padLeft(2, '0');
  }

  String get _seconds {
    final s = _secondsRemaining % 60;
    return s.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
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

                const SizedBox(height: 14),

                // 2. Deliver To Address & Delivery in 30 Mins Pill
                _buildDeliveryInfo(context),

                const SizedBox(height: 14),

                // 3. Search Bar with Filter Icon
                _buildSearchBar(context),

                const SizedBox(height: 16),

                // 4. Hero Promotional Banner ("Trendy Fashion Delivered Fast")
                _buildHeroBanner(context),

                const SizedBox(height: 18),

                // 5. Circular Category Icons Row
                _buildCategoriesRow(context),

                const SizedBox(height: 20),

                // 6. Today's Special Deals Section (with active countdown & deal cards)
                _buildSpecialDeals(context),

                const SizedBox(height: 22),

                // 7. New Arrivals Section
                _buildNewArrivals(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Top App Bar
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
                          style: TextStyle(color: Color(0xFFE61858)),
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
                      Consumer(
                        builder: (context, ref, _) {
                          final cartList = ref.watch(cartProvider);
                          final cartCount =
                              cartList.fold(0, (sum, i) => sum + i.quantity);
                          if (cartCount == 0) return const SizedBox.shrink();
                          return Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3.5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE61858),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          );
                        },
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

  // 2. Deliver To Address & Delivery in 30 Mins Pill
  Widget _buildDeliveryInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Address Info
          InkWell(
            onTap: () => context.push('/address-list'),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFE61858),
                  size: 22,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Deliver to Home',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF18181B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Indira Nagar, Lucknow - 226016',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF71717A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 30 Minutes Delivery Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.delivery_dining_rounded,
                  color: Color(0xFFE61858),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Delivery in',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '30 Minutes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE61858),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Search Bar with Filter Icon
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => context.push('/search'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
          ),
          child: Row(
            children: const [
              Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search for clothes, brands, or styles...',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: Color(0xFF18181B), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Hero Promotional Banner
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => context.go('/categories'),
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/home_banner.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  // 5. Circular Category Icons Row
  Widget _buildCategoriesRow(BuildContext context) {
    final categories = [
      {'title': 'Women', 'image': 'assets/images/cat_women.png'},
      {'title': 'Men', 'image': 'assets/images/cat_men.png'},
      {'title': 'Kids', 'image': 'assets/images/cat_kids.png'},
      {'title': 'Footwear', 'image': 'assets/images/cat_footwear.png'},
      {'title': 'Bags', 'image': 'assets/images/cat_bags.png'},
      {'title': 'Accessories', 'image': 'assets/images/cat_accessories.png'},
    ];

    return SizedBox(
      height: 94,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return InkWell(
            onTap: () => context.go('/categories'),
            borderRadius: BorderRadius.circular(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8ED),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(cat['image']!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['title']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18181B),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 6. Today's Special Deals Section
  Widget _buildSpecialDeals(BuildContext context) {
    final deals = [
      {
        'title': 'Women Dresses',
        'discount': 'Up to 50% Off',
        'image': 'assets/images/deal_women.png',
      },
      {
        'title': 'Men Clothing',
        'discount': 'Up to 40% Off',
        'image': 'assets/images/deal_men.png',
      },
      {
        'title': 'Kids Wear',
        'discount': 'Up to 50% Off',
        'image': 'assets/images/deal_kids.png',
      },
      {
        'title': 'Footwear',
        'discount': 'Up to 40% Off',
        'image': 'assets/images/deal_shoes.png',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                      ),
                      children: [
                        TextSpan(text: "Today's "),
                        TextSpan(
                          text: 'Special Deals',
                          style: TextStyle(color: Color(0xFFE61858)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Best fashion at best prices',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF71717A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              // Countdown Timer
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Ends in',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE61858),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _buildTimerBox(_hours, 'Hrs'),
                      const SizedBox(width: 4),
                      _buildTimerBox(_minutes, 'Min'),
                      const SizedBox(width: 4),
                      _buildTimerBox(_seconds, 'Sec'),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Deals Horizontal Cards
          SizedBox(
            height: 154,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: deals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final deal = deals[index];
                return InkWell(
                  onTap: () => context.go('/categories'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 122,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
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
                        // Deal Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.asset(
                            deal['image']!,
                            height: 94,
                            width: 122,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Title & Discount Row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deal['title']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    deal['discount']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE61858),
                                    ),
                                  ),
                                  Container(
                                    width: 19,
                                    height: 19,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE61858),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }

  Widget _buildTimerBox(String value, String unit) {
    return Container(
      width: 25,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE61858),
              height: 1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF71717A),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 7. New Arrivals Section
  Widget _buildNewArrivals(BuildContext context) {
    final products = [
      {
        'id': 1,
        'title': 'Women Top',
        'price': '₹799',
        'image': 'assets/images/arrival_card_1.png',
      },
      {
        'id': 2,
        'title': 'Men Shirt',
        'price': '₹999',
        'image': 'assets/images/arrival_card_2.png',
      },
      {
        'id': 3,
        'title': 'Dress',
        'price': '₹1,299',
        'image': 'assets/images/arrival_card_3.png',
      },
      {
        'id': 4,
        'title': 'Sneakers',
        'price': '₹1,499',
        'image': 'assets/images/arrival_card_4.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "New Arrivals" and "See All ->"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Arrivals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: () => context.go('/categories'),
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE61858),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFFE61858),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4 Cards Row matching the exact design
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardWidth = ((availableWidth - 30) / 4).clamp(96.0, 140.0);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(products.length, (index) {
                    final prod = products[index];
                    final prodId = prod['id'] as int;
                    final wishlist = ref.watch(wishlistProvider);
                    final isFavorited = wishlist.any(
                      (p) =>
                          p.id == 'arrival_$prodId' ||
                          (p.title.isNotEmpty &&
                              p.title.toLowerCase() ==
                                  prod['title'].toString().toLowerCase()),
                    );

                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < products.length - 1 ? 10.0 : 0.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          final cleanPrice = (prod['price'] as String)
                              .replaceAll(RegExp(r'[^\d]'), '');
                          final priceNum = int.tryParse(cleanPrice) ?? 999;
                          final origPrice = (priceNum * 1.35).round();

                          context.push(
                            '/product-details',
                            extra: {
                              'id': 'arrival_$prodId',
                              'title': prod['title'],
                              'name': prod['title'],
                              'brand': 'ModaRapp',
                              'price': prod['price'],
                              'originalPrice': '₹$origPrice',
                              'discount': '26% OFF',
                              'image': prod['image'],
                              'imageUrl': prod['image'],
                              'rating': 4.7,
                              'reviews': '1.2K',
                              'category': 'Fashion',
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Image with smooth rounded corners
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AspectRatio(
                                    aspectRatio: 225 / 230,
                                    child: Image.asset(
                                      prod['image'] as String,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // Interactive Heart Toggle Overlay
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      final cleanPrice =
                                          (prod['price'] as String).replaceAll(
                                            RegExp(r'[^\d]'),
                                            '',
                                          );
                                      final priceNum =
                                          int.tryParse(cleanPrice) ?? 999;
                                      final product = Product(
                                        id: 'arrival_$prodId',
                                        title: prod['title'] as String,
                                        brand: 'ModaRapp',
                                        imageUrl: prod['image'] as String,
                                        price: priceNum.toDouble(),
                                        originalPrice: (priceNum * 1.35),
                                        rating: 4.7,
                                        reviewsCount: 1200,
                                        weight: 'M',
                                        description:
                                            'Trendy ${prod['title']} from ModaRapp Collection',
                                        category: 'Fashion',
                                      );
                                      ref
                                          .read(wishlistProvider.notifier)
                                          .toggleWishlist(product);
                                      final nowWishlisted = !isFavorited;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                nowWishlisted
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                        .favorite_border_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  nowWishlisted
                                                      ? '${prod['title']} added to Wishlist'
                                                      : '${prod['title']} removed from Wishlist',
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: nowWishlisted
                                              ? const Color(0xFFE61858)
                                              : const Color(0xFF3F3F46),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          action: nowWishlisted
                                              ? SnackBarAction(
                                                  label: 'VIEW',
                                                  textColor: Colors.white,
                                                  onPressed: () {
                                                    try {
                                                      context.go('/wishlist');
                                                    } catch (_) {
                                                      try {
                                                        context.push(
                                                          '/wishlist',
                                                        );
                                                      } catch (_) {}
                                                    }
                                                  },
                                                )
                                              : null,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isFavorited
                                            ? Colors.white
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        boxShadow: isFavorited
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: isFavorited
                                            ? const Icon(
                                                Icons.favorite_rounded,
                                                size: 15,
                                                color: Color(0xFFE61858),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Price
                            Text(
                              prod['price'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 3),

                            // Title
                            Text(
                              prod['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
