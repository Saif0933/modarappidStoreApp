import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/products_provider.dart';

class OrderSuccessPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderSuccessPage({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends ConsumerState<OrderSuccessPage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _scratchCardRevealed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final int val = amount.round();
    final isNegative = val < 0;
    final absVal = val.abs();
    final s = absVal.toString();
    if (s.length <= 3) {
      return '${isNegative ? "- " : ""}₹$s';
    }
    final lastThree = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final regExp = RegExp(r'(\d+?)(?=(\d{2})+$)');
    final formattedRest = rest.replaceAllMapped(regExp, (Match m) => '${m[1]},');
    return '${isNegative ? "- " : ""}₹$formattedRest,$lastThree';
  }

  void _copyOrderId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Order ID ${widget.orderId} copied!'),
          ],
        ),
        backgroundColor: const Color(0xFF18181B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showScratchCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Woohoo! You Won!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Flat ₹100 Cashback on your next purchase above ₹999!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF52525B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFDEE7), width: 1.5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CASHBACK100',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE61858),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(const ClipboardData(text: 'CASHBACK100'));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coupon code CASHBACK100 copied!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFFE61858)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _scratchCardRevealed = true);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE61858),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Awesome, Thanks!',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
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
    final orderList = ref.watch(ordersProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    // Find the specific placed order or fall back to the most recent one
    final Order currentOrder = orderList.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => orderList.isNotEmpty
          ? orderList.first
          : Order(
              id: widget.orderId,
              items: const [
                CartItem(
                  product: Product(
                    id: 'c1',
                    brand: 'JCOSTA',
                    title: 'JCOSTA Men Solid Casual Black Shirt',
                    imageUrl: 'assets/images/cart_item_black_shirt.png',
                    price: 699.0,
                    originalPrice: 999.0,
                    rating: 4.8,
                    reviewsCount: 320,
                    weight: 'M',
                    description: 'Men Solid Casual Black Shirt with breathable cotton fabric.',
                    category: 'Shirts',
                  ),
                  quantity: 1,
                  selectedSize: 'M',
                  selectedColor: 'Black',
                ),
                CartItem(
                  product: Product(
                    id: 'c2',
                    brand: "Levi's",
                    title: "Levi's Men Slim Fit Jeans",
                    imageUrl: 'assets/images/cart_item_levis_jeans.png',
                    price: 1499.0,
                    originalPrice: 2299.0,
                    rating: 4.7,
                    reviewsCount: 450,
                    weight: '32',
                    description: 'Classic durable slim fit denim jeans for men.',
                    category: 'Jeans',
                  ),
                  quantity: 1,
                  selectedSize: '32',
                  selectedColor: 'Blue',
                ),
              ],
              totalAmount: 2328.0,
              date: DateTime.now(),
              status: 'Processing',
            ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Floating Confetti Particles in Background
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(),
                ),
              ),
            ),

            // Main Scrollable Content
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 740 : double.infinity),
                child: Column(
                  children: [
                    // Top Mini Navigation Bar
                    _buildTopNavBar(context),

                    // Scrollable Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // 1. Celebratory Hero Section
                            _buildHeroCelebration(),

                            const SizedBox(height: 18),

                            // 2. 30-Minute Delivery Live Status Banner
                            _buildLiveDeliveryCard(),

                            const SizedBox(height: 14),

                            // 3. Order ID & Details Card
                            _buildOrderIdCard(context, currentOrder),

                            const SizedBox(height: 14),

                            // 4. Ordered Items Preview Card
                            _buildOrderItemsCard(currentOrder),

                            const SizedBox(height: 14),

                            // 5. Delivery Address Card
                            _buildDeliveryAddressCard(selectedAddress),

                            const SizedBox(height: 14),

                            // 6. Gamified Mystery Reward Scratch Card
                            _buildRewardsCard(context),

                            const SizedBox(height: 24),

                            // 7. Action Buttons (Track Order, Continue Shopping)
                            _buildActionButtons(context),

                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Top Mini Navigation Bar
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close / Back button to Home
          InkWell(
            onTap: () => context.go('/home'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF18181B)),
            ),
          ),

          // Order Placed Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFBF2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                SizedBox(width: 5),
                Text(
                  'Order Confirmed',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),

          // Help / Support
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support is available 24/7 for your order.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
              ),
              child: const Icon(Icons.help_outline_rounded, size: 20, color: Color(0xFF71717A)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. Celebratory Hero Section with Animated Pulse Rings
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroCelebration() {
    return Column(
      children: [
        // Pulsing Rings with Checkmark Icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.08);
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow Ring
                Container(
                  width: 104 * scale,
                  height: 104 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE61858).withValues(alpha: 0.12 - (_pulseController.value * 0.05)),
                  ),
                ),

                // Middle Ring
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE61858).withValues(alpha: 0.18),
                  ),
                ),

                // Main Core Circle
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF2A6D), Color(0xFFE61858)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4DE61858),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1200.ms, delay: 400.ms),

        const SizedBox(height: 18),

        // Bold Celebration Headline
        const Text(
          'Order Placed Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF18181B),
            letterSpacing: -0.4,
          ),
        )
            .animate()
            .fade(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0.0),

        const SizedBox(height: 6),

        // Celebration Subtitle
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Woohoo! Your payment is confirmed and our delivery pilot is getting your fashion ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF71717A),
              height: 1.4,
            ),
          ),
        )
            .animate()
            .fade(duration: 400.ms, delay: 300.ms),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. 30-Minute Delivery Live Status Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildLiveDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Live Pulse
          Row(
            children: [
              // Delivery Scooter Icon
              Image.asset(
                'assets/images/cart_delivery_scooter.png',
                width: 34,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.two_wheeler_rounded,
                  size: 26,
                  color: Color(0xFFE61858),
                ),
              ),

              const SizedBox(width: 10),

              // Headline & ETA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '30-Minute Express Delivery',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Estimated Arrival: In 28-30 minutes',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Live Indicator Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFBF2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF16A34A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4-Stage Live Progress Stepper
          _buildLiveTimeline(),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms, delay: 350.ms)
        .slideY(begin: 0.1, end: 0.0);
  }

  Widget _buildLiveTimeline() {
    return Column(
      children: [
        Row(
          children: [
            _buildTimelineNode(isDone: true, icon: Icons.check_rounded),
            Expanded(child: Container(height: 2.5, color: const Color(0xFF16A34A))),
            _buildTimelineNode(isDone: true, isCurrent: true, icon: Icons.inventory_2_rounded),
            Expanded(child: Container(height: 2.5, color: const Color(0xFFE4E4E7))),
            _buildTimelineNode(isDone: false, icon: Icons.two_wheeler_rounded),
            Expanded(child: Container(height: 2.5, color: const Color(0xFFE4E4E7))),
            _buildTimelineNode(isDone: false, icon: Icons.home_rounded),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SizedBox(
              width: 55,
              child: Text(
                'Placed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                'Packing',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE61858)),
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                'On the way',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA)),
              ),
            ),
            SizedBox(
              width: 55,
              child: Text(
                'Delivered',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineNode({required bool isDone, bool isCurrent = false, required IconData icon}) {
    if (isCurrent) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Color(0xFFE61858),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x40E61858), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Center(child: Icon(icon, size: 14, color: Colors.white)),
      );
    } else if (isDone) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFF16A34A),
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(icon, size: 12, color: Colors.white)),
      );
    } else {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD4D4D8), width: 1.5),
        ),
        child: Center(child: Icon(icon, size: 11, color: const Color(0xFFA1A1AA))),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Order ID & Details Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildOrderIdCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Order ID with Copy Icon
          Expanded(
            child: InkWell(
              onTap: () => _copyOrderId(context),
              borderRadius: BorderRadius.circular(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_outlined, size: 18, color: Color(0xFFE61858)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Reference',
                          style: TextStyle(fontSize: 10, color: Color(0xFF71717A), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Text(
                              widget.orderId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF71717A)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Payment Status Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFBF2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_rounded, size: 12, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text(
                  'UPI Paid',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. Ordered Items Preview Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildOrderItemsCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Items in this Order (${order.items.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCurrency(order.totalAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE61858),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items preview list
          ...order.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: const Color(0xFFF4F4F5),
                      child: Image.asset(
                        item.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.checkroom_rounded,
                          size: 22,
                          color: Color(0xFF71717A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Size: ${item.selectedSize ?? item.product.weight} • Color: ${item.selectedColor ?? "Black"} • Qty: ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCurrency(item.product.price * item.quantity),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 1, color: Color(0xFFF1F1F4)),
          const SizedBox(height: 8),

          // Green Savings Tag
          Row(
            children: const [
              Icon(Icons.savings_rounded, size: 14, color: Color(0xFF16A34A)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'You saved ₹1,000 on this order!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. Delivery Address Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildDeliveryAddressCard(Address? address) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFFE61858)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        address?.name ?? 'Home',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18181B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF71717A)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${address?.addressLine ?? "Indira Nagar, House No. 123,"} ${address?.city ?? "Lucknow, Uttar Pradesh - 226016"}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF52525B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Phone: ${address?.phone ?? "+91 98765 43210"}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
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
  // 6. Gamified Mystery Reward Scratch Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildRewardsCard(BuildContext context) {
    return InkWell(
      onTap: () => _showScratchCardDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF1F2), Color(0xFFFFFBEB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE4E6), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _scratchCardRevealed ? '🎉' : '🎁',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scratchCardRevealed ? '₹100 Cashback Unlocked!' : 'You Unlocked a Mystery Scratch Card!',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _scratchCardRevealed
                        ? 'Code CASHBACK100 ready to use on next order'
                        : 'Tap to scratch and win up to ₹150 instant reward',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE61858),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _scratchCardRevealed ? 'VIEW' : 'SCRATCH',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 7. Action Buttons (Track Order, Continue Shopping)
  // ─────────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary: Track Order Live (prominent pink button)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context.push('/order-tracking', extra: widget.orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE61858),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.navigation_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Track Order Live',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Secondary: Continue Shopping (clean white outlined button)
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE4E4E7), width: 1.0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Tertiary: View Order Details Text Link
        InkWell(
          onTap: () {
            context.push('/order-details');
          },
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'View Order Receipt & Details',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF71717A),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Custom Confetti Painter for Celebration Effect
// ─────────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> _pieces = [
    _ConfettiPiece(Offset(0.15, 0.08), const Color(0xFFE61858), 6, true),
    _ConfettiPiece(Offset(0.82, 0.06), const Color(0xFFF59E0B), 5, false),
    _ConfettiPiece(Offset(0.28, 0.16), const Color(0xFF10B981), 4, false),
    _ConfettiPiece(Offset(0.72, 0.14), const Color(0xFF8B5CF6), 7, true),
    _ConfettiPiece(Offset(0.08, 0.22), const Color(0xFF3B82F6), 5, false),
    _ConfettiPiece(Offset(0.92, 0.20), const Color(0xFFEC4899), 6, true),
    _ConfettiPiece(Offset(0.20, 0.28), const Color(0xFFF59E0B), 4, true),
    _ConfettiPiece(Offset(0.80, 0.30), const Color(0xFF10B981), 5, false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in _pieces) {
      final paint = Paint()
        ..color = piece.color.withValues(alpha: 0.65)
        ..style = PaintingStyle.fill;

      final pos = Offset(piece.relPos.dx * size.width, piece.relPos.dy * size.height);

      if (piece.isCircle) {
        canvas.drawCircle(pos, piece.size, paint);
      } else {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: piece.size * 1.5, height: piece.size), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiPiece {
  final Offset relPos;
  final Color color;
  final double size;
  final bool isCircle;

  const _ConfettiPiece(this.relPos, this.color, this.size, this.isCircle);
}
