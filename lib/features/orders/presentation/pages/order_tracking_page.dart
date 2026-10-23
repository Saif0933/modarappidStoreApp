import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../address/data/services/ola_maps_service.dart';

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingPage({
    super.key,
    this.orderId = 'MRP12345678',
  });

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _timer;
  bool _isLocating = false;
  String _currentOlaAddress = 'Indira Nagar, Lucknow - 226016';

  // Rider progress along the route (0.0 = Store, 1.0 = Destination)
  double _riderProgress = 0.58;

  @override
  void initState() {
    super.initState();

    // Pulse animation for active delivery vehicle on the Ola map
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Simulated real-time rider progression
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _riderProgress += 0.04;
          if (_riderProgress > 0.85) {
            _riderProgress = 0.58;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOlaLocation() async {
    setState(() => _isLocating = true);

    try {
      // Fetch user's live reverse geocoded address via Ola Maps Platform API
      final result = await OlaMapsService.reverseGeocode(
        latitude: 26.8833,
        longitude: 80.9982,
      );

      if (mounted) {
        setState(() {
          _isLocating = false;
          if (result.formattedAddress.isNotEmpty) {
            _currentOlaAddress = result.formattedAddress;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ola Maps: Location refreshed to $_currentOlaAddress',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE61858),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
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
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. Top App Bar (Back Arrow, ModaRapp Logo, Help)
              _buildTopAppBar(context),

              const SizedBox(height: 12),

              // 2. Scrollable Body
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: "Order Tracking" + "Arriving in 12 Minutes"
                          _buildOrderHeader(),

                          const SizedBox(height: 16),

                          // Horizontal 5-Step Progress Tracker
                          _buildHorizontalStepper(),

                          const SizedBox(height: 18),

                          // Interactive Ola Maps Tracking View
                          _buildOlaMapView(),

                          const SizedBox(height: 16),

                          // Delivery Partner Card (Rohit Kumar)
                          _buildDeliveryPartnerCard(context),

                          const SizedBox(height: 18),

                          // Order Items (2)
                          _buildOrderItemsSection(context),

                          const SizedBox(height: 18),

                          // Tracking Details Vertical Stepper
                          _buildVerticalTrackingDetails(),

                          const SizedBox(height: 20),

                          // Bottom Action Buttons
                          _buildBottomActionButtons(context),

                          const SizedBox(height: 24),
                        ],
                      ),
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
          // Back Button + Logo + Title
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/orders');
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

          // Help Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support agent will connect shortly.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: const [
                  Icon(
                    Icons.headset_mic_outlined,
                    size: 18,
                    color: Color(0xFF18181B),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Help',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
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

  // 2. Order Header ("Order Tracking" + "Arriving in 12 Minutes")
  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Order ID
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Tracking',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Order #${widget.orderId}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // "Arriving in 12 Minutes" Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Arriving in',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1),
              Text(
                '12 Minutes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE61858),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Horizontal 5-Step Stepper
  Widget _buildHorizontalStepper() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Order Placed
            _buildStepperItem(
              icon: Icons.check_rounded,
              isDone: true,
              isActive: false,
              title: 'Order Placed',
              time: '10:15 AM',
            ),

            // Line 1
            _buildStepperLine(isCompleted: true),

            // Step 2: Confirmed
            _buildStepperItem(
              icon: Icons.check_rounded,
              isDone: true,
              isActive: false,
              title: 'Confirmed',
              time: '10:17 AM',
            ),

            // Line 2
            _buildStepperLine(isCompleted: true),

            // Step 3: Packed
            _buildStepperItem(
              icon: Icons.check_rounded,
              isDone: true,
              isActive: false,
              title: 'Packed',
              time: '10:25 AM',
            ),

            // Line 3
            _buildStepperLine(isCompleted: true),

            // Step 4: Out for Delivery (Active)
            _buildStepperItem(
              icon: Icons.local_shipping_rounded,
              isDone: false,
              isActive: true,
              title: 'Out for Delivery',
              time: '10:32 AM',
            ),

            // Line 4
            _buildStepperLine(isCompleted: false),

            // Step 5: Delivered
            _buildStepperItem(
              icon: Icons.home_outlined,
              isDone: false,
              isActive: false,
              title: 'Delivered',
              time: 'On the way',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepperItem({
    required IconData icon,
    required bool isDone,
    required bool isActive,
    required String title,
    required String time,
  }) {
    Color circleColor;
    Color iconColor;
    Widget circleContent;

    if (isDone) {
      circleColor = const Color(0xFFE61858);
      iconColor = Colors.white;
      circleContent = Icon(icon, size: 14, color: iconColor);
    } else if (isActive) {
      circleColor = const Color(0xFFE61858);
      iconColor = Colors.white;
      circleContent = Icon(icon, size: 15, color: iconColor);
    } else {
      circleColor = const Color(0xFFF4F4F6);
      iconColor = const Color(0xFF71717A);
      circleContent = Icon(icon, size: 14, color: iconColor);
    }

    return Expanded(
      flex: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle with Halo if active
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE61858).withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
              border: isActive
                  ? Border.all(color: const Color(0xFFFDE8ED), width: 3)
                  : null,
            ),
            child: Center(child: circleContent),
          ),

          const SizedBox(height: 6),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive
                  ? const Color(0xFF18181B)
                  : (isDone ? const Color(0xFF18181B) : const Color(0xFF71717A)),
              height: 1.15,
            ),
          ),

          const SizedBox(height: 2),

          // Time
          Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8.5,
              color: Color(0xFF71717A),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperLine({required bool isCompleted}) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          height: 2.2,
          color: isCompleted
              ? const Color(0xFFE61858)
              : const Color(0xFFE4E4E7),
        ),
      ),
    );
  }

  // 4. Interactive Ola Maps Tracking View
  Widget _buildOlaMapView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 434 / 170,
          child: Stack(
            children: [
              // High-res Ola Maps visual tile base
              Positioned.fill(
                child: Image.asset(
                  'assets/images/order_map_view.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Animated Rider Scooter position on the route
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Positioned(
                    top: 88,
                    left: 200 + (_riderProgress - 0.58) * 120,
                    child: child!,
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE61858),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE61858).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.two_wheeler_rounded,
                      size: 17,
                      color: Color(0xFFE61858),
                    ),
                  ),
                ),
              ),

              // "Powered by Ola Maps" subtle badge in top-left
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.map_rounded,
                        size: 11,
                        color: Color(0xFFE61858),
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Ola Maps Platform',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18181B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating Target / Locate Button (Bottom Right)
              Positioned(
                bottom: 10,
                right: 10,
                child: InkWell(
                  onTap: _isLocating ? null : _fetchOlaLocation,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLocating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE61858),
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              size: 17,
                              color: Color(0xFF18181B),
                            ),
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

  // 5. Delivery Partner Card (Rohit Kumar)
  Widget _buildDeliveryPartnerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Green Status Dot
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/driver_rohit_kumar.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Partner Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rohit Kumar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Your Delivery Partner',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 2),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '(320 deliveries)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF71717A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Call & Chat Circular Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Call Button
              _buildPartnerActionButton(
                icon: Icons.phone_rounded,
                label: 'Call',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calling Rohit Kumar (+91 98765 43210)...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              const SizedBox(width: 12),

              // Chat Button
              _buildPartnerActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening live chat with Rohit Kumar...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 17,
                color: const Color(0xFFE61858),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Order Items (2)
  Widget _buildOrderItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: "Order Items (2)" + "View Details >"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Order Items (2)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                context.push('/order-history');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE61858),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: Color(0xFFE61858),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Item 1: Men Oversized T-Shirt
        _buildItemRow(
          image: 'assets/images/order_item_tshirt.png',
          title: 'Men Oversized T-Shirt',
          specs: 'Size: L  |  Color: Black  |  Qty: 1',
          price: '₹699',
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: Color(0xFFF4F4F6)),
        ),

        // Item 2: Slim Fit Jeans
        _buildItemRow(
          image: 'assets/images/order_item_jeans.png',
          title: 'Slim Fit Jeans',
          specs: 'Size: 32  |  Color: Blue  |  Qty: 1',
          price: '₹1,499',
        ),
      ],
    );
  }

  Widget _buildItemRow({
    required String image,
    required String title,
    required String specs,
    required String price,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            image,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                specs,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF71717A),
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF18181B),
          ),
        ),
      ],
    );
  }

  // 7. Tracking Details Vertical Stepper
  Widget _buildVerticalTrackingDetails() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 16),

          // Milestone 1: Order Placed
          _buildVerticalMilestone(
            icon: Icons.check_rounded,
            isDone: true,
            isActive: false,
            isLast: false,
            title: 'Order Placed',
            subtitle: 'Your order has been placed successfully.',
            time: '10:15 AM',
          ),

          // Milestone 2: Order Confirmed
          _buildVerticalMilestone(
            icon: Icons.check_rounded,
            isDone: true,
            isActive: false,
            isLast: false,
            title: 'Order Confirmed',
            subtitle: 'The seller has confirmed your order.',
            time: '10:17 AM',
          ),

          // Milestone 3: Packed
          _buildVerticalMilestone(
            icon: Icons.check_rounded,
            isDone: true,
            isActive: false,
            isLast: false,
            title: 'Packed',
            subtitle: 'Your items are packed and ready for delivery.',
            time: '10:25 AM',
          ),

          // Milestone 4: Out for Delivery (Active)
          _buildVerticalMilestone(
            icon: Icons.local_shipping_rounded,
            isDone: false,
            isActive: true,
            isLast: false,
            title: 'Out for Delivery',
            subtitle: 'Your order is out for delivery.',
            time: '10:32 AM',
          ),

          // Milestone 5: Delivered
          _buildVerticalMilestone(
            icon: Icons.home_outlined,
            isDone: false,
            isActive: false,
            isLast: true,
            title: 'Delivered',
            subtitle: 'Order will be delivered soon.',
            time: 'Expected\n10:44 AM',
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalMilestone({
    required IconData icon,
    required bool isDone,
    required bool isActive,
    required bool isLast,
    required String title,
    required String subtitle,
    required String time,
  }) {
    Color circleColor;
    Color iconColor;
    Widget circleContent;

    if (isDone) {
      circleColor = const Color(0xFFE61858);
      iconColor = Colors.white;
      circleContent = Icon(icon, size: 13, color: iconColor);
    } else if (isActive) {
      circleColor = const Color(0xFFE61858);
      iconColor = Colors.white;
      circleContent = Icon(icon, size: 14, color: iconColor);
    } else {
      circleColor = const Color(0xFFF4F4F6);
      iconColor = const Color(0xFF71717A);
      circleContent = Icon(icon, size: 13, color: iconColor);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle + Vertical Line
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFE61858).withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1.5,
                          ),
                        ]
                      : null,
                  border: isActive
                      ? Border.all(
                          color: const Color(0xFFFDE8ED),
                          width: 2.5,
                        )
                      : null,
                ),
                child: Center(child: circleContent),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? const Color(0xFFE61858)
                        : (isActive
                            ? const Color(0xFFE61858)
                            : const Color(0xFFE4E4E7)),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w900 : FontWeight.w700,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF71717A),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF71717A),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 8. Bottom Action Buttons (Cancel Order, Return / Exchange, Need Help?)
  Widget _buildBottomActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Cancel Order
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order cancellation request initiated.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFE61858),
                      width: 1.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          Icons.close_rounded,
                          size: 14,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Cancel Order',
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
              ),
            ),

            const SizedBox(width: 8),

            // Return / Exchange
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Return / Exchange eligible after delivery.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFE61858),
                      width: 1.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          Icons.replay_rounded,
                          size: 14,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Return / Exchange',
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
              ),
            ),

            const SizedBox(width: 8),

            // Need Help?
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening 24x7 Customer Support...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFE61858),
                      width: 1.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          Icons.headset_mic_outlined,
                          size: 14,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Need Help?',
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
              ),
            ),
          ],
        );
      },
    );
  }
}
