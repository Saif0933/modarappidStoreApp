import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  String _selectedFilter = 'All Orders (5)';

  final List<String> _filters = [
    'All Orders (5)',
    'Processing (1)',
    'Out for Delivery (1)',
    'Delivered (3)',
    'Cancelled',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 1. Top App Bar (ModaRapp Logo, Bell, Cart Badge)
                _buildTopAppBar(context),

                const SizedBox(height: 16),

                // 2. Screen Title: "My Orders"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Horizontal Filter Chips
                _buildFilterChips(),

                const SizedBox(height: 16),

                // 4. Orders List
                _buildOrdersList(context),

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

  // 2. Horizontal Filter Chips
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

  // 3. Orders List based on Selected Filter
  Widget _buildOrdersList(BuildContext context) {
    final showCard1 = _selectedFilter == 'All Orders (5)' ||
        _selectedFilter == 'Processing (1)';
    final showCard2 = _selectedFilter == 'All Orders (5)' ||
        _selectedFilter == 'Out for Delivery (1)';
    final showCard3 = _selectedFilter == 'All Orders (5)' ||
        _selectedFilter == 'Delivered (3)';
    final showCancelled = _selectedFilter == 'Cancelled';

    if (showCancelled) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.remove_shopping_cart_outlined,
                  size: 48, color: Color(0xFF71717A)),
              SizedBox(height: 12),
              Text(
                'No Cancelled Orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'You have not cancelled any orders yet.',
                style: TextStyle(fontSize: 13, color: Color(0xFF71717A)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (showCard1) ...[
            _buildOrderCard1(context),
            const SizedBox(height: 16),
          ],
          if (showCard2) ...[
            _buildOrderCard2(context),
            const SizedBox(height: 16),
          ],
          if (showCard3) ...[
            _buildOrderCard3(context),
          ],
        ],
      ),
    );
  }

  // --- CARD 1: Order #ORD123456 (Preparing) ---
  Widget _buildOrderCard1(BuildContext context) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(
            orderId: 'Order #ORD123456',
            orderDate: '22 Oct 2026, 01:30 PM',
            statusLabel: 'Preparing',
            statusBgColor: const Color(0xFFFDF2F4),
            statusTextColor: const Color(0xFFE61858),
            onTap: () => context.push('/order-tracking'),
          ),

          const SizedBox(height: 12),

          // Product Item Row
          _buildProductRow(
            imagePath: 'assets/images/order_prod_dress.png',
            title: 'Women Floral Dress',
            subtitle: 'Size: M  |  Qty: 1',
            price: '₹1,299',
          ),

          const SizedBox(height: 14),

          // 5-Step Tracking Stepper
          _buildTrackingStepper(
            steps: [
              _StepInfo(
                title: 'Order Placed',
                time: '01:30 PM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Confirmed',
                time: '01:35 PM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Preparing',
                time: '',
                status: _StepStatus.active,
                activeIcon: Icons.card_giftcard_rounded,
              ),
              _StepInfo(
                title: 'Out for Delivery',
                time: '',
                status: _StepStatus.pending,
                pendingIcon: Icons.local_shipping_outlined,
              ),
              _StepInfo(
                title: 'Delivered',
                time: '',
                status: _StepStatus.pending,
                pendingIcon: Icons.check_rounded,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons: Cancel Order & Chat with Seller
          Row(
            children: [
              // Cancel Order Button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(context, '#ORD123456');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE61858),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 17,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Cancel Order',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE61858),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Chat with Seller Button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening chat with seller...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDE8ED),
                      foregroundColor: const Color(0xFFE61858),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_rounded,
                          size: 15,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Chat with Seller',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  // --- CARD 2: Order #ORD123455 (Out for Delivery) ---
  Widget _buildOrderCard2(BuildContext context) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(
            orderId: 'Order #ORD123455',
            orderDate: '21 Oct 2026, 11:10 AM',
            statusLabel: 'Out for Delivery',
            statusBgColor: const Color(0xFFEDFCF2),
            statusTextColor: const Color(0xFF16A34A),
            onTap: () => context.push('/order-tracking'),
          ),

          const SizedBox(height: 12),

          // Product Item Row
          _buildProductRow(
            imagePath: 'assets/images/order_prod_shirt.png',
            title: 'Men Casual Shirt',
            subtitle: 'Size: L  |  Qty: 1',
            price: '₹999',
          ),

          const SizedBox(height: 14),

          // 5-Step Tracking Stepper
          _buildTrackingStepper(
            steps: [
              _StepInfo(
                title: 'Order Placed',
                time: '11:10 AM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Confirmed',
                time: '11:15 AM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Preparing',
                time: '11:25 AM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Out for Delivery',
                time: '11:40 AM',
                status: _StepStatus.active,
                activeIcon: Icons.local_shipping_rounded,
              ),
              _StepInfo(
                title: 'Delivered',
                time: '',
                status: _StepStatus.pending,
                pendingIcon: Icons.check_rounded,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Delivery Partner Card (Rohan Kumar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Avatar
                ClipOval(
                  child: Image.asset(
                    'assets/images/order_rohan_kumar.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 10),

                // Partner Name & Rating
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rohan Kumar',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18181B),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Your delivery partner',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF71717A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 2),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Phone Call Action Button
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling delivery partner...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.phone_rounded,
                        color: Color(0xFFE61858),
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Chat Action Button
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening chat with Rohan...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: Color(0xFFE61858),
                        size: 17,
                      ),
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

  // --- CARD 3: Order #ORD123420 (Delivered) ---
  Widget _buildOrderCard3(BuildContext context) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(
            orderId: 'Order #ORD123420',
            orderDate: '18 Oct 2026, 06:20 PM',
            statusLabel: 'Delivered',
            statusBgColor: const Color(0xFFEDFCF2),
            statusTextColor: const Color(0xFF16A34A),
            onTap: () => context.push('/order-tracking'),
          ),

          const SizedBox(height: 12),

          // Product Item Row
          _buildProductRow(
            imagePath: 'assets/images/order_prod_sneakers.png',
            title: 'Women Sneakers',
            subtitle: 'Size: 38  |  Qty: 1',
            price: '₹1,499',
          ),

          const SizedBox(height: 14),

          // 5-Step Tracking Stepper (All 5 completed)
          _buildTrackingStepper(
            steps: [
              _StepInfo(
                title: 'Order Placed',
                time: '06:20 PM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Confirmed',
                time: '06:25 PM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Preparing',
                time: '06:40 PM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Out for Delivery',
                time: '07:05 PM',
                status: _StepStatus.completed,
              ),
              _StepInfo(
                title: 'Delivered',
                time: '07:22 PM',
                status: _StepStatus.completed,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons: Return/Exchange & Buy Again
          Row(
            children: [
              // Return/Exchange Button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting Return/Exchange flow...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE61858),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restart_alt_rounded,
                          size: 17,
                          color: Color(0xFFE61858),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Return/Exchange',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE61858),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Buy Again Button
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/cart');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE61858),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Buy Again',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- REUSABLE CARD CONTAINER ---
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFEFF2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // --- REUSABLE ORDER HEADER ---
  Widget _buildOrderHeader({
    required String orderId,
    required String orderDate,
    required String statusLabel,
    required Color statusBgColor,
    required Color statusTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Order ID & Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                orderDate,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          // Status Badge with Chevron
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: statusTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF71717A),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- REUSABLE PRODUCT ROW ---
  Widget _buildProductRow({
    required String imagePath,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Row(
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 68,
            height: 68,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 12),

        // Title, Subtitle, Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18181B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- REUSABLE TRACKING STEPPER ---
  Widget _buildTrackingStepper({required List<_StepInfo> steps}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isFirst = index == 0;
        final isLast = index == steps.length - 1;

        // Line before this node
        final isLeftLineActive = isFirst
            ? false
            : steps[index - 1].status == _StepStatus.completed;

        // Line after this node
        final isRightLineActive = isLast
            ? false
            : step.status == _StepStatus.completed;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Left line + Circle + Right line
              SizedBox(
                height: 22,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Connecting line
                    Positioned.fill(
                      child: Row(
                        children: [
                          // Left half of line
                          Expanded(
                            child: isFirst
                                ? const SizedBox.shrink()
                                : Container(
                                    height: 2,
                                    color: isLeftLineActive
                                        ? const Color(0xFFE61858)
                                        : const Color(0xFFE4E4E7),
                                  ),
                          ),
                          // Right half of line
                          Expanded(
                            child: isLast
                                ? const SizedBox.shrink()
                                : Container(
                                    height: 2,
                                    color: isRightLineActive
                                        ? const Color(0xFFE61858)
                                        : const Color(0xFFE4E4E7),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Center Circle Indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: step.status == _StepStatus.pending
                            ? const Color(0xFFE4E4E7)
                            : const Color(0xFFE61858),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          step.status == _StepStatus.completed
                              ? Icons.check_rounded
                              : (step.status == _StepStatus.active
                                  ? (step.activeIcon ?? Icons.check_rounded)
                                  : (step.pendingIcon ?? Icons.check_rounded)),
                          color: step.status == _StepStatus.pending
                              ? const Color(0xFFA1A1AA)
                              : Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // Title
              Text(
                step.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 9.0,
                  fontWeight: step.status == _StepStatus.pending
                      ? FontWeight.w500
                      : FontWeight.w700,
                  color: step.status == _StepStatus.pending
                      ? const Color(0xFF71717A)
                      : const Color(0xFF18181B),
                  height: 1.1,
                ),
              ),

              if (step.time.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  step.time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // --- CANCEL ORDER CONFIRMATION DIALOG ---
  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel $orderId?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Order',
              style: TextStyle(color: Color(0xFF71717A)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$orderId has been cancelled'),
                  backgroundColor: const Color(0xFFE61858),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE61858),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

enum _StepStatus {
  completed,
  active,
  pending,
}

class _StepInfo {
  final String title;
  final String time;
  final _StepStatus status;
  final IconData? activeIcon;
  final IconData? pendingIcon;

  _StepInfo({
    required this.title,
    required this.time,
    required this.status,
    this.activeIcon,
    this.pendingIcon,
  });
}
