import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductCategoriesPage extends ConsumerStatefulWidget {
  final String categoryName;

  const ProductCategoriesPage({
    super.key,
    this.categoryName = "Men's Fashion",
  });

  @override
  ConsumerState<ProductCategoriesPage> createState() =>
      _ProductCategoriesPageState();
}

class _ProductCategoriesPageState extends ConsumerState<ProductCategoriesPage> {
  int _selectedSubcatIndex = 0;
  String _selectedSort = 'Sort';
  String? _selectedFilterChip = 'Sort';
  bool _isGridView = true;
  final Set<int> _wishlistedProductIds = {};

  // 12 Subcategories for the Left Rail
  final List<Map<String, String>> _subcategories = [
    {'title': 'All', 'icon': 'assets/images/subcat_icon_all.png'},
    {'title': 'T-Shirts', 'icon': 'assets/images/subcat_icon_tshirts.png'},
    {'title': 'Shirts', 'icon': 'assets/images/subcat_icon_shirts.png'},
    {'title': 'Jeans', 'icon': 'assets/images/subcat_icon_jeans.png'},
    {'title': 'Trousers', 'icon': 'assets/images/subcat_icon_trousers.png'},
    {'title': 'Shorts', 'icon': 'assets/images/subcat_icon_shorts.png'},
    {'title': 'Jackets', 'icon': 'assets/images/subcat_icon_jackets.png'},
    {'title': 'Hoodies', 'icon': 'assets/images/subcat_icon_hoodies.png'},
    {'title': 'Ethnic Wear', 'icon': 'assets/images/subcat_icon_ethnic.png'},
    {'title': 'Active Wear', 'icon': 'assets/images/subcat_icon_active.png'},
    {'title': 'Innerwear', 'icon': 'assets/images/subcat_icon_innerwear.png'},
    {'title': 'Accessories', 'icon': 'assets/images/subcat_icon_accessories.png'},
  ];

  // Filter Chips
  final List<String> _filterChips = [
    'Sort',
    'Size',
    'Brand',
    'Color',
    'Price',
  ];

  // 6 Main Products
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'title': 'Oversized T-Shirt',
      'brand': 'Roadster',
      'rating': '4.5',
      'reviews': '(2.1K)',
      'price': '₹699',
      'originalPrice': '₹999',
      'discount': '30% OFF',
      'image': 'assets/images/cat_prod_1.png',
      'category': 'T-Shirts',
    },
    {
      'id': 2,
      'title': 'Casual Shirt',
      'brand': 'Peter England',
      'rating': '4.3',
      'reviews': '(1.8K)',
      'price': '₹1,199',
      'originalPrice': '₹1,699',
      'discount': '29% OFF',
      'image': 'assets/images/cat_prod_2.png',
      'category': 'Shirts',
    },
    {
      'id': 3,
      'title': 'Slim Fit Jeans',
      'brand': "Levi's",
      'rating': '4.6',
      'reviews': '(3.2K)',
      'price': '₹1,499',
      'originalPrice': '₹2,299',
      'discount': '35% OFF',
      'image': 'assets/images/cat_prod_3.png',
      'category': 'Jeans',
    },
    {
      'id': 4,
      'title': 'Formal Trousers',
      'brand': 'Allen Solly',
      'rating': '4.4',
      'reviews': '(1.9K)',
      'price': '₹1,299',
      'originalPrice': '₹1,999',
      'discount': '35% OFF',
      'image': 'assets/images/cat_prod_4.png',
      'category': 'Trousers',
    },
    {
      'id': 5,
      'title': 'Hoodie',
      'brand': 'HRX',
      'rating': '4.5',
      'reviews': '(1.2K)',
      'price': '₹1,199',
      'originalPrice': '₹1,799',
      'discount': '33% OFF',
      'image': 'assets/images/cat_prod_5.png',
      'category': 'Hoodies',
    },
    {
      'id': 6,
      'title': 'Kurta',
      'brand': 'Manyavar',
      'rating': '4.6',
      'reviews': '(1.5K)',
      'price': '₹1,399',
      'originalPrice': '₹1,999',
      'discount': '30% OFF',
      'image': 'assets/images/cat_prod_6.png',
      'category': 'Ethnic Wear',
    },
  ];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 1. Top App Bar (Back Arrow, ModaRapp Logo, Search, Heart, Cart)
              _buildTopAppBar(context),

              const SizedBox(height: 10),

              // 2. Headline: "Men's Fashion" & Subtitle
              _buildHeadline(),

              const SizedBox(height: 12),

              // 3. Main Content: Left Vertical Rail + Right Product Area
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Rail: Subcategories
                        _buildLeftSubcategoryRail(),

                        // Vertical Subtle Divider
                        Container(
                          width: 1,
                          color: const Color(0xFFF1F1F4),
                        ),

                        // Right Area: Banner + Filters + Product Grid
                        Expanded(
                          child: _buildRightProductArea(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
          // Left: Back Arrow + Logo + Title
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF18181B),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/modarapp_logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 18,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF71717A),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Search + Heart + Cart
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Icon
              InkWell(
                onTap: () => context.push('/search'),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF18181B),
                    size: 23,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Wishlist Heart Icon
              InkWell(
                onTap: () => context.push('/wishlist'),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFF18181B),
                    size: 23,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Cart with Badge '3'
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
                        size: 24,
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
                              fontSize: 9.0,
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

  // 2. Headline Section
  Widget _buildHeadline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.categoryName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Discover the latest trends in men's clothing",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF71717A),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Left Rail: Subcategories
  Widget _buildLeftSubcategoryRail() {
    return Container(
      width: 78,
      color: const Color(0xFFFAFAFC),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        physics: const BouncingScrollPhysics(),
        itemCount: _subcategories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final subcat = _subcategories[index];
          final isSelected = index == _selectedSubcatIndex;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedSubcatIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF0F3) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE61858)
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  SizedBox(
                    height: 30,
                    child: Image.asset(
                      subcat['icon']!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
                  Text(
                    subcat['title']!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFE61858)
                          : const Color(0xFF71717A),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Right Area: Promo Banner + Filter Bar + Count/Toggle + Product Grid
  Widget _buildRightProductArea(BuildContext context) {
    // Filter products if a subcategory is selected (other than 'All')
    final activeSubcatTitle = _subcategories[_selectedSubcatIndex]['title'];
    final displayedProducts = (activeSubcatTitle == 'All')
        ? _products
        : _products
            .where((p) => p['category'] == activeSubcatTitle)
            .toList();

    final productList =
        displayedProducts.isEmpty ? _products : displayedProducts;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Promotional Banner: "Men's Collection"
          _buildPromoBanner(context),

          const SizedBox(height: 12),

          // B. Horizontal Filter & Sort Chips
          _buildFilterChipsRow(),

          const SizedBox(height: 10),

          // C. Product Count & Grid/List View Toggle
          _buildCountAndToggleRow(productList.length),

          const SizedBox(height: 10),

          // D. Product Listing (Grid or List View)
          _isGridView
              ? _buildProductGrid(context, productList)
              : _buildProductList(context, productList),
        ],
      ),
    );
  }

  // A. Promotional Banner
  Widget _buildPromoBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFFDE8ED),
        ),
        child: AspectRatio(
          aspectRatio: 358 / 114,
          child: Image.asset(
            'assets/images/cat_prod_banner.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // B. Filter & Sort Chips Row
  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filterChips.map((chip) {
          final isSort = chip == 'Sort';
          final isSelected = chip == _selectedFilterChip;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilterChip = chip;
                });
                if (chip == 'Sort') {
                  _showSortBottomSheet(context);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: (isSort || isSelected)
                      ? const Color(0xFFFFF0F3)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isSort || isSelected)
                        ? const Color(0xFFE61858)
                        : const Color(0xFFE4E4E7),
                    width: (isSort || isSelected) ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSort) ...[
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 14,
                        color: Color(0xFFE61858),
                      ),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      chip == 'Sort' && _selectedSort != 'Sort'
                          ? _selectedSort
                          : chip,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            (isSort || isSelected) ? FontWeight.w800 : FontWeight.w600,
                        color: (isSort || isSelected)
                            ? const Color(0xFFE61858)
                            : const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: (isSort || isSelected)
                          ? const Color(0xFFE61858)
                          : const Color(0xFF71717A),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // C. Product Count & Grid / List View Toggle
  Widget _buildCountAndToggleRow(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Product Count
        Text(
          '342 Products',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF18181B),
          ),
        ),

        // Grid / List Toggle Icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grid Toggle Button
            InkWell(
              onTap: () {
                setState(() {
                  _isGridView = true;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isGridView
                      ? const Color(0xFFFFF0F3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 18,
                  color: _isGridView
                      ? const Color(0xFFE61858)
                      : const Color(0xFFA1A1AA),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // List Toggle Button
            InkWell(
              onTap: () {
                setState(() {
                  _isGridView = false;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !_isGridView
                      ? const Color(0xFFFFF0F3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.view_agenda_outlined,
                  size: 18,
                  color: !_isGridView
                      ? const Color(0xFFE61858)
                      : const Color(0xFFA1A1AA),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // D. 2-Column Product Grid (Responsive for Phone & Tablet)
  Widget _buildProductGrid(
      BuildContext context, List<Map<String, dynamic>> productList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet supports 3 or 4 columns, phone has 2 columns
        final isTablet = constraints.maxWidth >= 550;
        final crossAxisCount = isTablet ? 3 : 2;
        const spacing = 10.0;
        final totalSpacing = spacing * (crossAxisCount - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: productList.map((prod) {
            return SizedBox(
              width: cardWidth,
              child: _buildProductCard(context, prod),
            );
          }).toList(),
        );
      },
    );
  }

  // List View Mode
  Widget _buildProductList(
      BuildContext context, List<Map<String, dynamic>> productList) {
    return Column(
      children: productList.map((prod) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildProductListItem(context, prod),
        );
      }).toList(),
    );
  }

  // Product Card in Grid
  Widget _buildProductCard(
      BuildContext context, Map<String, dynamic> prod) {
    final prodId = prod['id'] as int;
    final isWishlisted = _wishlistedProductIds.contains(prodId);

    return InkWell(
      onTap: () {
        context.push('/product-details', extra: prod);
      },
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Floating Heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 174 / 136,
                  child: Image.asset(
                    prod['image'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Floating Heart Button
              Positioned(
                top: 7,
                right: 7,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isWishlisted) {
                        _wishlistedProductIds.remove(prodId);
                      } else {
                        _wishlistedProductIds.add(prodId);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isWishlisted
                              ? '${prod['title']} removed from Wishlist'
                              : '${prod['title']} added to Wishlist',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 15,
                        color: isWishlisted
                            ? const Color(0xFFE61858)
                            : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // Title
          Text(
            prod['title'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18181B),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 1),

          // Brand
          Text(
            prod['brand'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF71717A),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 3),

          // Rating: ★ 4.5 (2.1K)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 2),
              Text(
                prod['rating'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                prod['reviews'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF71717A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Price Row: ₹699 ₹999 30% OFF
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(
                prod['price'] as String,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                ),
              ),
              Text(
                prod['originalPrice'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF71717A),
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  prod['discount'] as String,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE61858),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // "Add to Cart" Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${prod['title']} added to Cart!'),
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 13,
                      color: Color(0xFFE61858),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE61858),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Product Card in List View
  Widget _buildProductListItem(
      BuildContext context, Map<String, dynamic> prod) {
    final prodId = prod['id'] as int;
    final isWishlisted = _wishlistedProductIds.contains(prodId);

    return InkWell(
      onTap: () {
        context.push('/product-details', extra: prod);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F1F4)),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  prod['image'] as String,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          prod['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF18181B),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isWishlisted) {
                              _wishlistedProductIds.remove(prodId);
                            } else {
                              _wishlistedProductIds.add(prodId);
                            }
                          });
                        },
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isWishlisted
                              ? const Color(0xFFE61858)
                              : const Color(0xFF18181B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    prod['brand'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF71717A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    runSpacing: 2,
                    children: [
                      Text(
                        prod['price'] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF18181B),
                        ),
                      ),
                      Text(
                        prod['originalPrice'] as String,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF71717A),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          prod['discount'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE61858),
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
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sortOptions = [
          'Popularity',
          'Price: Low to High',
          'Price: High to Low',
          'Newest First',
          'Customer Rating',
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
              const Divider(height: 1),
              ...sortOptions.map((opt) {
                final isSelected = _selectedSort == opt;
                return ListTile(
                  dense: true,
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFE61858)
                          : const Color(0xFF18181B),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Color(0xFFE61858), size: 18)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSort = opt;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
