import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsPage({super.key, required this.productData});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  int _selectedThumbIndex = 0;
  int _selectedColorIndex = 0;
  String _selectedSize = 'M';
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _isDescriptionExpanded = true;

  final List<String> _thumbnails = [
    'assets/images/prod_thumb_1.png',
    'assets/images/prod_thumb_2.png',
    'assets/images/prod_thumb_3.png',
    'assets/images/prod_thumb_4.png',
  ];

  final List<String> _mainImages = [
    'assets/images/prod_detail_main.png',
    'assets/images/prod_thumb_2.png',
    'assets/images/prod_thumb_3.png',
    'assets/images/prod_thumb_4.png',
  ];

  final List<Map<String, String>> _colorSwatches = [
    {'name': 'Pink', 'image': 'assets/images/prod_swatch_pink.png'},
    {'name': 'Blue', 'image': 'assets/images/prod_swatch_blue.png'},
    {'name': 'White', 'image': 'assets/images/prod_swatch_white.png'},
    {'name': 'Black', 'image': 'assets/images/prod_swatch_black.png'},
  ];

  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

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
            children: [
              const SizedBox(height: 10),

              // 1. Top App Bar (Back Arrow, ModaRapp Logo, Heart, Cart)
              _buildTopAppBar(context),

              // 2. Scrollable Body (Responsive for Phone & Tablet)
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 550;

                            if (isWide) {
                              // Tablet / Desktop 2-Column Wide Layout
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 14),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left: Gallery
                                      SizedBox(
                                        width: 320,
                                        child: _buildGallery(context),
                                      ),
                                      const SizedBox(width: 24),
                                      // Right: Details
                                      Expanded(
                                        child: _buildProductDetailsInfo(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFeatureHighlights(),
                                  const SizedBox(height: 14),
                                  _buildDeliveryLocationCard(),
                                  const SizedBox(height: 14),
                                  _buildSellerCard(),
                                  const SizedBox(height: 14),
                                  _buildDescriptionSection(),
                                  const SizedBox(height: 30),
                                ],
                              );
                            }

                            // Phone Layout (Split Row for Top Gallery & Details)
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),

                                // Top Split: Gallery on Left + Info on Right
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Gallery
                                    SizedBox(
                                      width: (constraints.maxWidth - 12) * 0.46,
                                      child: _buildGallery(context),
                                    ),
                                    const SizedBox(width: 12),
                                    // Right: Details
                                    Expanded(
                                      child: _buildProductDetailsInfo(context),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // 3. Four Feature Highlights Bar
                                _buildFeatureHighlights(),

                                const SizedBox(height: 14),

                                // 4. Delivery to Home Card
                                _buildDeliveryLocationCard(),

                                const SizedBox(height: 14),

                                // 5. Sold by Seller Card
                                _buildSellerCard(),

                                const SizedBox(height: 14),

                                // 6. Product Description Accordion
                                _buildDescriptionSection(),

                                const SizedBox(height: 30),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 7. Sticky Bottom Action Bar
              _buildBottomActionBar(context),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top App Bar (Back Arrow, ModaRapp Logo, Heart, Cart)
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button & Logo
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

          // Heart Outline & Cart with '3' Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isWishlisted = !_isWishlisted;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isWishlisted
                          ? 'Added to Wishlist'
                          : 'Removed from Wishlist'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    _isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isWishlisted
                        ? const Color(0xFFE61858)
                        : const Color(0xFF18181B),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 6),

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

  // 2. Left Side: Product Gallery (Main Image + 4 Thumbnails)
  Widget _buildGallery(BuildContext context) {
    final currentImage = _mainImages[_selectedThumbIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Image with Zoom Button & 1/5 Page Pill
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 225 / 325,
                child: Image.asset(
                  currentImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Zoom / Fullscreen Button
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.open_in_full_rounded,
                    size: 14,
                    color: Color(0xFFE61858),
                  ),
                ),
              ),
            ),

            // 1 / 5 Page Indicator Pill
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '${_selectedThumbIndex + 1} / 5',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 4 Thumbnails in a Row
        Row(
          children: List.generate(_thumbnails.length, (index) {
            final isSelected = index == _selectedThumbIndex;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < _thumbnails.length - 1 ? 6 : 0,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedThumbIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE61858)
                            : const Color(0xFFEFEFF2),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AspectRatio(
                        aspectRatio: 51 / 62,
                        child: Image.asset(
                          _thumbnails[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 3. Right Side: Product Details Info (Badges, Title, Pricing, Color, Size, Qty)
  Widget _buildProductDetailsInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Best Seller" Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Best Seller',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE61858),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Product Title
        const Text(
          'Women Floral Dress',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Color(0xFF18181B),
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 3),

        // Subtitle
        const Text(
          'Trendy Floral Print Dress for Every Occasion',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF71717A),
            fontWeight: FontWeight.w400,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 6),

        // Rating Row
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Icon(
              Icons.star_rounded,
              size: 14,
              color: Color(0xFFF59E0B),
            ),
            SizedBox(width: 3),
            Text(
              '4.7',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18181B),
              ),
            ),
            SizedBox(width: 3),
            Text(
              '(1.2K reviews)',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF71717A),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 15,
              color: Color(0xFF71717A),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Price Row: ₹1,299 + ₹1,899 + 32% OFF
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          children: [
            const Text(
              '₹1,299',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE61858),
              ),
            ),
            const Text(
              '₹1,899',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF71717A),
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '32% OFF',
                style: TextStyle(
                  fontSize: 9.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE61858),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Flash Delivery Card: "⚡ Get it in 30 Minutes"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: Color(0xFFE61858),
                size: 17,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Get it in 30 Minutes',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE61858),
                      ),
                    ),
                    Text(
                      'Order within 15 mins',
                      style: TextStyle(
                        fontSize: 9.0,
                        color: Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: Color(0xFF71717A),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Color Selector: "Color: Pink"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Color',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18181B),
              ),
            ),
            Text(
              _colorSwatches[_selectedColorIndex]['name']!,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF71717A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 4 Color Swatches
        Row(
          children: List.generate(_colorSwatches.length, (index) {
            final isSelected = index == _selectedColorIndex;
            final swatch = _colorSwatches[index];

            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE61858)
                          : Colors.transparent,
                      width: 1.8,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      swatch['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Size Selector: "Size: 📏 Size Chart"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Size',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18181B),
              ),
            ),
            Flexible(
              child: InkWell(
                onTap: () {
                  _showSizeChartDialog(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.straighten_rounded,
                      size: 12,
                      color: Color(0xFFE61858),
                    ),
                    SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        'Size Chart',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE61858),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 5 Size Pills: S, M, L, XL, XXL
        Row(
          children: _sizes.map((size) {
            final isSelected = size == _selectedSize;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 3),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF0F3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE61858)
                            : const Color(0xFFE4E4E7),
                        width: 1.1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFE61858)
                              : const Color(0xFF18181B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Quantity Selector: "Quantity: [-] 1 [+]"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18181B),
              ),
            ),
            Container(
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
                    },
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(13),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.remove_rounded,
                        size: 13,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(13),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.add_rounded,
                        size: 13,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Feature Highlights Bar (Premium Quality, Soft, Easy Wash, 7 Days Return)
  Widget _buildFeatureHighlights() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDE8ED),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          _buildFeatureItem(
            icon: Icons.diamond_outlined,
            title: 'Premium',
            subtitle: 'Quality',
          ),
          _buildFeatureDivider(),
          _buildFeatureItem(
            icon: Icons.energy_savings_leaf_outlined,
            title: 'Soft &',
            subtitle: 'Comfortable',
          ),
          _buildFeatureDivider(),
          _buildFeatureItem(
            icon: Icons.local_laundry_service_outlined,
            title: 'Easy',
            subtitle: 'Wash',
          ),
          _buildFeatureDivider(),
          _buildFeatureItem(
            icon: Icons.assignment_return_outlined,
            title: '7 Days',
            subtitle: 'Return',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFFE61858),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF18181B),
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF71717A),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureDivider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFF1F1F4),
    );
  }

  // 5. Delivery to Home Card
  Widget _buildDeliveryLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Location Pin Icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_outlined,
                color: Color(0xFFE61858),
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Address Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Flexible(
                      child: Text(
                        'Delivery to Home',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18181B),
                        ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 30 Minutes Delivery Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.two_wheeler_rounded,
                  color: Color(0xFFE61858),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Delivery in',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: Color(0xFF71717A),
                      ),
                    ),
                    Text(
                      '30 Minutes',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE61858),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF71717A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Sold by Seller Card
  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Storefront Icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_rounded,
                color: Color(0xFFE61858),
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Seller Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sold by',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF71717A),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'ModaRapp Fashion',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18181B),
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: Color(0xFF71717A),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Seller Rating & Product Count
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFCF2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 2),
                    Text(
                      '4.6',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                '(2.3K products)',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF71717A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 7. Product Description Accordion
  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                    ),
                  ),
                ),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF18181B),
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isDescriptionExpanded) ...[
            const SizedBox(height: 10),
            const Text(
              'This beautiful floral dress is perfect for casual outings, parties and everyday wear. Made with premium quality fabric, it offers comfort and style for every occasion.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF71717A),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 8. Sticky Bottom Action Bar
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Heart Wishlist Button
          InkWell(
            onTap: () {
              setState(() {
                _isWishlisted = !_isWishlisted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isWishlisted
                      ? 'Added to Wishlist'
                      : 'Removed from Wishlist'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE4E4E7),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  _isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isWishlisted
                      ? const Color(0xFFE61858)
                      : const Color(0xFF18181B),
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // "Add to Cart" Button
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Women Floral Dress added to Cart!'),
                      backgroundColor: Color(0xFFE61858),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFE61858),
                    width: 1.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 16,
                        color: Color(0xFFE61858),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE61858),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // "Buy Now" Button
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/cart');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE61858),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSizeChartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Size Chart (in inches)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Bust', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Waist', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Length', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('S'), Text('34"'), Text('28"'), Text('36"')]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('M'), Text('36"'), Text('30"'), Text('37"')]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('L'), Text('38"'), Text('32"'), Text('38"')]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('XL'), Text('40"'), Text('34"'), Text('39"')]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('XXL'), Text('42"'), Text('36"'), Text('40"')]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFFE61858))),
          ),
        ],
      ),
    );
  }
}
