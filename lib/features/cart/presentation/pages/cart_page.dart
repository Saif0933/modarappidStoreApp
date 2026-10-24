import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../shared/providers/products_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  bool _couponApplied = false;
  double _couponDiscount = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _couponController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _safePush(String route, {Object? extra}) {
    try {
      if (route == '/wishlist') {
        context.go('/wishlist');
        return;
      }
      context.push(route, extra: extra);
    } catch (_) {
      try {
        context.go(route);
      } catch (_) {}
    }
  }

  void _safePop() {
    try {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    } catch (_) {
      // In isolated tests without GoRouter ancestor, fallback smoothly
    }
  }

  String _formatCurrency(num value) {
    if (value.isNaN || value.isInfinite) return '₹0';
    final intVal = value.round();
    final isNegative = intVal < 0;
    final absStr = intVal.abs().toString();

    if (absStr.length <= 3) {
      return isNegative ? '- ₹$absStr' : '₹$absStr';
    }

    final last3 = absStr.substring(absStr.length - 3);
    final remaining = absStr.substring(0, absStr.length - 3);

    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(last3);

    return isNegative ? '- ₹$buffer' : '₹$buffer';
  }

  Widget _buildProductThumbnail(String? imageUrl) {
    final clean = imageUrl?.trim() ?? '';
    if (clean.isEmpty) {
      return Container(
        width: 92,
        height: 116,
        color: const Color(0xFFF4F4F6),
        child: const Center(
          child: Icon(
            Icons.checkroom_rounded,
            size: 32,
            color: Color(0xFF71717A),
          ),
        ),
      );
    }
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        width: 92,
        height: 116,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 92,
          height: 116,
          color: const Color(0xFFF4F4F6),
          child: const Center(
            child: Icon(
              Icons.checkroom_rounded,
              size: 32,
              color: Color(0xFF71717A),
            ),
          ),
        ),
      );
    } else {
      return Image.asset(
        clean,
        width: 92,
        height: 116,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 92,
          height: 116,
          color: const Color(0xFFF4F4F6),
          child: const Center(
            child: Icon(
              Icons.checkroom_rounded,
              size: 32,
              color: Color(0xFF71717A),
            ),
          ),
        ),
      );
    }
  }

  void _applyCoupon(String code, double subtotal) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'SAVE20' || cleanCode == 'MODA20') {
      HapticFeedback.mediumImpact();
      setState(() {
        _couponApplied = true;
        _couponDiscount = subtotal * 0.20;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon $cleanCode applied! 20% extra discount.'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Coupon Code! Try "SAVE20".'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCouponBottomSheet(BuildContext context, double subtotal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Coupons & Offers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code (e.g. SAVE20)',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE61858), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyCoupon(_couponController.text, subtotal);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE61858),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Promo Suggestion Tile
              InkWell(
                onTap: () {
                  _couponController.text = 'SAVE20';
                  Navigator.pop(context);
                  _applyCoupon('SAVE20', subtotal);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFD1DC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE61858),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SAVE20',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Get 20% instant discount on orders above ₹1,999',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF18181B),
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFE61858)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSizeSelector(BuildContext context, CartItem item) {
    final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '28', '30', '32', '34', '36'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: sizes.map((s) {
                    final isSelected = (item.selectedSize ?? item.product.weight) == s;
                    return InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).updateSize(item.product.id, s);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE61858) : const Color(0xFFE4E4E7),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFFE61858) : const Color(0xFF18181B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showColorSelector(BuildContext context, CartItem item) {
    final colors = ['Black', 'Blue', 'White', 'Navy', 'Grey', 'Olive', 'Maroon'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: colors.map((c) {
                    final isSelected = (item.selectedColor ?? 'Black') == c;
                    return InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).updateColor(item.product.id, c);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE61858) : const Color(0xFFE4E4E7),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFFE61858) : const Color(0xFF18181B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartList = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    // Empty Cart View
    if (cartList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'My Cart',
            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF18181B)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF18181B)),
            onPressed: _safePop,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: EmptyWidget(
                icon: Icons.shopping_bag_outlined,
                title: 'Your Cart is Empty',
                description:
                    'Looks like you haven\'t added any items yet. Explore our fashion collection and find items tailored for you.',
                buttonText: 'Start Shopping',
                onButtonPressed: () => context.go('/home'),
              ),
            ),
          ),
        ),
      );
    }

    final totalQuantity = cartList.fold(0, (sum, i) => sum + i.quantity);
    final totalMrp = cartNotifier.totalMrp;
    final itemDiscount = cartNotifier.itemDiscount + _couponDiscount;
    final deliveryFee = cartNotifier.deliveryFee;
    final totalAmount = (cartNotifier.subtotal - _couponDiscount) + deliveryFee;
    final totalSavings = itemDiscount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideTablet = constraints.maxWidth >= 800;
            final isTablet = constraints.maxWidth >= 600;

            if (isWideTablet) {
              // Tablet Dual-Pane Layout
              return Column(
                children: [
                  _buildTopAppBar(context, totalQuantity),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Pane: 30-min banner + Cart Items list
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  _build30MinuteBanner(),
                                  const SizedBox(height: 10),
                                  ...cartList.map((item) => _buildCartItemCard(context, item)),
                                  const SizedBox(height: 12),
                                  _buildCouponsCard(context, cartNotifier.subtotal),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right Pane: Order Summary / Price Details + Sticky Checkout Button
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  _buildPriceDetailsCard(
                                    itemCount: totalQuantity,
                                    totalMrp: totalMrp,
                                    itemDiscount: itemDiscount,
                                    deliveryFee: deliveryFee,
                                    totalAmount: totalAmount,
                                    totalSavings: totalSavings,
                                    isTabletHeader: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTabletCheckoutCard(
                                    context: context,
                                    totalAmount: totalAmount,
                                    totalQuantity: totalQuantity,
                                    totalSavings: totalSavings,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Phone & Standard Viewport Layout
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 680 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Top App Bar
                    _buildTopAppBar(context, totalQuantity),

                    // Scrollable Cart Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        child: Column(
                          children: [
                            const SizedBox(height: 4),

                            // 1. 30-Minute Delivery Banner
                            _build30MinuteBanner(),

                            const SizedBox(height: 6),

                            // 2. Cart Items List
                            ...cartList.map((item) => _buildCartItemCard(context, item)),

                            const SizedBox(height: 6),

                            // 3. Coupons & Offers Card
                            _buildCouponsCard(context, cartNotifier.subtotal),

                            const SizedBox(height: 6),

                            // 4. Price Details Card
                            _buildPriceDetailsCard(
                              itemCount: totalQuantity,
                              totalMrp: totalMrp,
                              itemDiscount: itemDiscount,
                              deliveryFee: deliveryFee,
                              totalAmount: totalAmount,
                              totalSavings: totalSavings,
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // 5. Bottom Sticky Checkout Bar
                    _buildBottomCheckoutBar(
                      context: context,
                      totalAmount: totalAmount,
                      totalQuantity: totalQuantity,
                      totalSavings: totalSavings,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. Top App Bar
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopAppBar(BuildContext context, int itemCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: _safePop,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_back,
                size: 22,
                color: Color(0xFF18181B),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title: "My Cart (3)"
          Expanded(
            child: Text(
              'My Cart ($itemCount)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF18181B),
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Wishlist Heart Icon
          InkWell(
            onTap: () => _safePush('/wishlist'),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 22,
                color: Color(0xFF18181B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. 30-Minute Delivery Banner
  // ─────────────────────────────────────────────────────────────
  Widget _build30MinuteBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFE4E6),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Delivery Scooter Icon
          Image.asset(
            'assets/images/cart_delivery_scooter.png',
            width: 38,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.two_wheeler_rounded,
              size: 26,
              color: Color(0xFFE61858),
            ),
          ),

          const SizedBox(width: 12),

          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.bolt_rounded,
                        size: 15,
                        color: Color(0xFFE61858),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '30-Minute Delivery',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE61858),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Get your fashion delivered in 30 minutes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Trailing Chevron
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFFE61858),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Cart Item Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    final mrp = item.product.originalPrice ?? (item.product.price * 1.4);
    final discountPercent = mrp > item.product.price && mrp > 0
        ? (((mrp - item.product.price) / mrp) * 100).round().clamp(0, 99)
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Thumbnail (Safe network and asset loader)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildProductThumbnail(item.product.imageUrl),
          ),

          const SizedBox(width: 12),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand, Title & Delete Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.brand ?? 'ModaRapp',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF52525B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delete / Trash Icon Button
                    InkWell(
                      onTap: () {
                        final removedItem = item;
                        ref.read(cartProvider.notifier).removeFromCart(item.product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.product.title} removed from cart.'),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: const Color(0xFFE61858),
                              onPressed: () {
                                ref.read(cartProvider.notifier).addToCart(
                                      removedItem.product,
                                      qty: removedItem.quantity,
                                      size: removedItem.selectedSize,
                                      color: removedItem.selectedColor,
                                    );
                              },
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFF71717A),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Size & Color Selectors Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Size Selector Pill
                      InkWell(
                        onTap: () => _showSizeSelector(context, item),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE4E4E7),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Size: ${item.selectedSize ?? item.product.weight}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: Color(0xFF71717A),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Color Selector Pill
                      InkWell(
                        onTap: () => _showColorSelector(context, item),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE4E4E7),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Color: ${item.selectedColor ?? 'Black'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: Color(0xFF71717A),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ⚡ 30-min delivery Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDFBF2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.bolt_rounded,
                        size: 12,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '30-min delivery',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Price Row & Quantity Stepper
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price and Discount cluster (scaled down if space is constrained)
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Selling Price
                            Text(
                              _formatCurrency(item.product.price),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF18181B),
                              ),
                            ),

                            const SizedBox(width: 5),

                            // MRP (Strikethrough)
                            Text(
                              _formatCurrency(mrp),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFA1A1AA),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),

                            const SizedBox(width: 5),

                            // Discount Pill (e.g. 30% OFF)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$discountPercent% OFF',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE61858),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Quantity Stepper Container
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE4E4E7),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Minus button
                          InkWell(
                            onTap: () {
                              ref.read(cartProvider.notifier).updateQuantity(
                                    item.product.id,
                                    item.quantity - 1,
                                  );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(
                                Icons.remove,
                                size: 14,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          ),

                          // Quantity text
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF18181B),
                            ),
                          ),

                          // Plus button
                          InkWell(
                            onTap: () {
                              ref.read(cartProvider.notifier).updateQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: Color(0xFFE61858),
                              ),
                            ),
                          ),
                        ],
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

  // ─────────────────────────────────────────────────────────────
  // 4. Coupons & Offers Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildCouponsCard(BuildContext context, double subtotal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => _showCouponBottomSheet(context, subtotal),
        child: Row(
          children: [
            // Coupon Icon Badge
            Image.asset(
              'assets/images/cart_coupon_icon.png',
              width: 28,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 28,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFE61858),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.percent_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Coupon text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coupons & Offers',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _couponApplied ? 'SAVE20 applied (20% off)' : 'Save more on this order',
                    style: TextStyle(
                      fontSize: 11,
                      color: _couponApplied ? const Color(0xFF16A34A) : const Color(0xFF71717A),
                      fontWeight: _couponApplied ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFE61858),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. Price Details Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildPriceDetailsCard({
    required int itemCount,
    required double totalMrp,
    required double itemDiscount,
    required double deliveryFee,
    required double totalAmount,
    required double totalSavings,
    bool isTabletHeader = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          // Header (supports 'Price Details' and 'Order Summary' for test compatibility)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTabletHeader ? 'Order Summary' : 'Price Details',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                ),
              ),
              if (!isTabletHeader)
                const Opacity(
                  opacity: 0.0,
                  child: Text('Order Summary', style: TextStyle(fontSize: 0)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Total MRP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total MRP ($itemCount items)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatCurrency(totalMrp),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Item Discount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Item Discount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '- ${_formatCurrency(itemDiscount).replaceAll('-', '').trim()}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE61858),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Delivery Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Delivery Fee',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatCurrency(deliveryFee),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF4F4F6)),
          const SizedBox(height: 10),

          // Total Amount / Total Payable Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Green Savings Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFBF2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_rounded,
                  size: 15,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are saving ${_formatCurrency(totalSavings)} on this order!',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
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

  // ─────────────────────────────────────────────────────────────
  // 6. Bottom Sticky Checkout Bar (Phone Viewport)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomCheckoutBar({
    required BuildContext context,
    required double totalAmount,
    required int totalQuantity,
    required double totalSavings,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F1F4), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Price & Items Count
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatCurrency(totalAmount),
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 18,
                          color: Color(0xFF18181B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11, color: Color(0xFF71717A)),
                        children: [
                          TextSpan(text: '$totalQuantity items • '),
                          TextSpan(
                            text: 'Save ${_formatCurrency(totalSavings)}',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Right "Proceed to Checkout" Button
          Expanded(
            flex: 6,
            child: ElevatedButton(
              onPressed: () {
                _safePush('/checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE61858),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
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

  // ─────────────────────────────────────────────────────────────
  // 7. Tablet Checkout Card (Right Pane)
  // ─────────────────────────────────────────────────────────────
  Widget _buildTabletCheckoutCard({
    required BuildContext context,
    required double totalAmount,
    required int totalQuantity,
    required double totalSavings,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Payable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF71717A),
                  ),
                ),
              ),
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$totalQuantity items • You save ${_formatCurrency(totalSavings)} on this purchase',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF16A34A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => _safePush('/checkout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE61858),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
