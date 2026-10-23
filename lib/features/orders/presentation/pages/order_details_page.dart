import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../address/data/services/ola_maps_service.dart';

/// Enum representing the 6 distinct order statuses supported by the screen
enum OrderDetailStatus {
  delivered,
  cancelled,
  refunded,
  returnRequested,
  returning,
  returnRefunded,
}

class OrderDetailsPage extends ConsumerStatefulWidget {
  final OrderDetailStatus? initialStatus;
  final String? orderId;

  const OrderDetailsPage({
    super.key,
    this.initialStatus = OrderDetailStatus.delivered,
    this.orderId,
  });

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late OrderDetailStatus _currentStatus;
  late String _orderId;

  // Interactive state
  int _userRating = 0;
  bool _isOlaMapExpanded = false;
  bool _isLocatingOla = false;
  String? _geocodedAddress;

  // Animation controller for pulse / transition
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus ?? OrderDetailStatus.delivered;
    _orderId = widget.orderId ?? 'OD438063137903616100';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _changeStatus(OrderDetailStatus newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchOlaLocation() async {
    setState(() => _isLocatingOla = true);
    try {
      // Indira Nagar, Lucknow coordinates (Delivery address from image)
      final res = await OlaMapsService.reverseGeocode(
        latitude: 26.8917,
        longitude: 80.9944,
      );
      if (mounted) {
        setState(() {
          _geocodedAddress = res.formattedAddress;
          _isLocatingOla = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ola Maps Location: ${res.locality}, ${res.city}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocatingOla = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 680 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Top App Bar
                    _buildAppBar(context),

                    // Quick Status Switcher Pill Bar (Allows testing all 6 states instantly)
                    _buildStatusSwitcherBar(),

                    // Scrollable Order Details Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Product Summary Card (Common)
                            _buildProductSummaryCard(),

                            const SizedBox(height: 12),

                            // 2. Status Banner (Delivered / Cancelled / Refunded / etc.)
                            _buildStatusBanner(),

                            const SizedBox(height: 14),

                            // 3. Status-Specific Content Cards
                            ..._buildStatusSpecificCards(context),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // 4. Bottom Action Bar (if applicable for status)
                    _buildBottomBar(context),
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
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Arrow
          InkWell(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/orders');
              }
            },
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

          const SizedBox(width: 10),

          // Title
          const Expanded(
            child: Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF18181B),
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Help Pill Button
          InkWell(
            onTap: () {
              _showHelpDialog(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
              ),
              child: const Text(
                'Help',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Status Switcher Pill Bar (For seamless preview of all 6 states)
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatusSwitcherBar() {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F1F4), width: 1),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _buildStatusPill(
            label: 'Delivered',
            status: OrderDetailStatus.delivered,
            color: const Color(0xFF16A34A),
          ),
          _buildStatusPill(
            label: 'Cancelled',
            status: OrderDetailStatus.cancelled,
            color: const Color(0xFFDC2626),
          ),
          _buildStatusPill(
            label: 'Refunded (Amber)',
            status: OrderDetailStatus.refunded,
            color: const Color(0xFFD97706),
          ),
          _buildStatusPill(
            label: 'Return Requested',
            status: OrderDetailStatus.returnRequested,
            color: const Color(0xFF9333EA),
          ),
          _buildStatusPill(
            label: 'Returning',
            status: OrderDetailStatus.returning,
            color: const Color(0xFF2563EB),
          ),
          _buildStatusPill(
            label: 'Refunded (Green)',
            status: OrderDetailStatus.returnRefunded,
            color: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required String label,
    required OrderDetailStatus status,
    required Color color,
  }) {
    final isSelected = _currentStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _changeStatus(status),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? color : const Color(0xFF71717A),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Product Summary Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildProductSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shirt Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/jcosta_black_shirt.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFFF4F4F6),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      color: Color(0xFF71717A),
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title, Specs, Price & Qty
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JCOSTA Men Solid Casual Black Shirt',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Size: M  •  Color: Black',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Text(
                          '₹699',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Qty: 1',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF71717A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF4F4F6)),
          const SizedBox(height: 8),

          // Order ID with Copy Icon
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #$_orderId',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(_orderId, 'Order ID'),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: Color(0xFF2563EB),
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
  // 3. Status Banner
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatusBanner() {
    Color bgColor;
    Color borderColor;
    Color iconCircleColor;
    Widget iconWidget;
    String title;
    Color titleColor;
    String subtitle;
    Color subtitleColor;

    switch (_currentStatus) {
      case OrderDetailStatus.delivered:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        iconCircleColor = const Color(0xFF16A34A);
        iconWidget = const Icon(Icons.check_rounded, color: Colors.white, size: 14);
        title = 'Delivered, Jul 17';
        titleColor = const Color(0xFF166534);
        subtitle = 'Your order has been delivered successfully.';
        subtitleColor = const Color(0xFF15803D);
        break;

      case OrderDetailStatus.cancelled:
        bgColor = const Color(0xFFFFF1F2);
        borderColor = const Color(0xFFFFE4E6);
        iconCircleColor = const Color(0xFFDC2626);
        iconWidget = const Icon(Icons.close_rounded, color: Colors.white, size: 14);
        title = 'Cancelled, Jul 16';
        titleColor = const Color(0xFF991B1B);
        subtitle = 'Your order has been cancelled.';
        subtitleColor = const Color(0xFFDC2626);
        break;

      case OrderDetailStatus.refunded:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        iconCircleColor = const Color(0xFFD97706);
        iconWidget = const Center(
          child: Text(
            '₹',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
        title = 'Refunded, Jul 20';
        titleColor = const Color(0xFF92400E);
        subtitle = 'Your refund has been processed.';
        subtitleColor = const Color(0xFFB45309);
        break;

      case OrderDetailStatus.returnRequested:
        bgColor = const Color(0xFFFAF5FF);
        borderColor = const Color(0xFFF3E8FF);
        iconCircleColor = const Color(0xFF9333EA);
        iconWidget = const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 13);
        title = 'Return Requested, Jul 19';
        titleColor = const Color(0xFF6B21A8);
        subtitle = 'Your return request has been submitted. We will pick up the item soon.';
        subtitleColor = const Color(0xFF7E22CE);
        break;

      case OrderDetailStatus.returning:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFDBEAFE);
        iconCircleColor = const Color(0xFF2563EB);
        iconWidget = const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 13);
        title = 'Returning, Jul 21';
        titleColor = const Color(0xFF1E40AF);
        subtitle = 'Your item has been picked up and is on the way to our warehouse.';
        subtitleColor = const Color(0xFF1D4ED8);
        break;

      case OrderDetailStatus.returnRefunded:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        iconCircleColor = const Color(0xFF16A34A);
        iconWidget = const Icon(Icons.sync_rounded, color: Colors.white, size: 14);
        title = 'Refunded, Jul 24';
        titleColor = const Color(0xFF166534);
        subtitle = 'Your return has been accepted and refund has been processed.';
        subtitleColor = const Color(0xFF15803D);
        break;
    }

    return InkWell(
      onTap: () => _showStatusSelectorBottomSheet(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Circular Status Icon
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: iconCircleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                ),
                const SizedBox(width: 8),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),

                // Dropdown Chevron
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: titleColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. Status-Specific Cards
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildStatusSpecificCards(BuildContext context) {
    switch (_currentStatus) {
      case OrderDetailStatus.delivered:
        return [
          _buildDeliveryDetailsCard(context),
          const SizedBox(height: 14),
          _buildRateYourExperienceCard(),
        ];

      case OrderDetailStatus.cancelled:
        return [
          _buildCancellationDetailsCard(),
          const SizedBox(height: 14),
          _buildPaymentDetailsCard(),
          const SizedBox(height: 14),
          _buildNeedHelpCard(context),
        ];

      case OrderDetailStatus.refunded:
        return [
          _buildRefundDetailsCard(
            refundDate: 'Sat, 20 Jul, 2024 at 02:15 PM',
            txnId: 'T2024072014152635',
          ),
          const SizedBox(height: 14),
          _buildProductDetailsCard(),
        ];

      case OrderDetailStatus.returnRequested:
        return [
          _buildReturnDetailsCard(),
          const SizedBox(height: 14),
          _buildProductDetailsCard(),
        ];

      case OrderDetailStatus.returning:
        return [
          _buildReturnTrackingCard(context),
          const SizedBox(height: 14),
          _buildProductDetailsCard(),
        ];

      case OrderDetailStatus.returnRefunded:
        return [
          _buildRefundDetailsCard(
            refundDate: 'Wed, 24 Jul, 2024 at 11:20 AM',
            txnId: 'T2024072411203589',
          ),
          const SizedBox(height: 14),
          _buildProductDetailsCard(),
        ];
    }
  }

  // ── Delivery Details Card (with Ola Maps integration) ─────────
  Widget _buildDeliveryDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 14),

          // Delivered on
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Delivered on',
            value: 'Wed, 17 Jul, 2024 at 04:20 PM',
          ),
          const SizedBox(height: 12),

          // Delivered to
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Delivered to',
            value: 'Rohit Kumar',
          ),
          const SizedBox(height: 12),

          // Home address
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Home',
            value: _geocodedAddress ?? 'Indira Nagar, Lucknow, Uttar Pradesh',
          ),
          const SizedBox(height: 14),

          const Divider(height: 1, color: Color(0xFFF4F4F6)),
          const SizedBox(height: 10),

          // View tracking details (Ola Maps Integration trigger)
          InkWell(
            onTap: () {
              setState(() {
                _isOlaMapExpanded = !_isOlaMapExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_outlined,
                    size: 18,
                    color: Color(0xFF18181B),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'View tracking details',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ),
                  Icon(
                    _isOlaMapExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.chevron_right_rounded,
                    size: 20,
                    color: const Color(0xFF71717A),
                  ),
                ],
              ),
            ),
          ),

          // Ola Maps Interactive Preview (Animated expansion)
          if (_isOlaMapExpanded) ...[
            const SizedBox(height: 12),
            _buildOlaMapPreviewCard(context),
          ],
        ],
      ),
    );
  }

  // ── Ola Maps Interactive Preview Card ────────────────────────
  Widget _buildOlaMapPreviewCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map canvas with route
          Stack(
            children: [
              Image.asset(
                'assets/images/order_map_view.png',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Icon(Icons.map, size: 40, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),

              // Ola Maps Platform Branding Chip
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
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
                      SizedBox(width: 4),
                      Text(
                        'Ola Maps Platform',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18181B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // GPS Geocode button
              Positioned(
                bottom: 8,
                right: 8,
                child: InkWell(
                  onTap: _isLocatingOla ? null : _fetchOlaLocation,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLocatingOla
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: Color(0xFFE61858),
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              size: 16,
                              color: Color(0xFF18181B),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Map Action Row
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Delivered via ModaRapp Express on Ola Maps',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.push('/order-tracking', extra: _orderId);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Live Track',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE61858),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFFE61858),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Rate your experience Card ─────────────────────────────────
  Widget _buildRateYourExperienceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate your experience',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 12),

          // Inner Product Rating Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4E7), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: Color(0xFF18181B),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Rate the product',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5 Interactive Stars
                Row(
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    final isFilled = _userRating >= starIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _userRating = starIndex;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Thank you! Rated $starIndex / 5 stars.'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 26,
                          color: isFilled
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFA1A1AA),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Cancellation Details Card ─────────────────────────────────
  Widget _buildCancellationDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cancellation Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 14),

          // Cancelled on
          _buildDetailRow(
            icon: Icons.description_outlined,
            label: 'Cancelled on',
            value: 'Tue, 16 Jul, 2024 at 11:30 AM',
          ),
          const SizedBox(height: 12),

          // Reason
          _buildDetailRow(
            icon: Icons.info_outline_rounded,
            label: 'Reason',
            value: 'Cancelled by you',
          ),
        ],
      ),
    );
  }

  // ── Payment Details Card ──────────────────────────────────────
  Widget _buildPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Color(0xFF18181B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '₹699',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF18181B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Refunded to original payment method on 16 Jul, 2024',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71717A),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Need help with this order? Card ───────────────────────────
  Widget _buildNeedHelpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: InkWell(
        onTap: () => _showHelpDialog(context),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Need help with this order?',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Contact our support team.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF71717A),
            ),
          ],
        ),
      ),
    );
  }

  // ── Refund Details Card (Used by refunded & returnRefunded) ───
  Widget _buildRefundDetailsCard({
    required String refundDate,
    required String txnId,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Refund Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 14),

          // Refunded on
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Refunded on',
            value: refundDate,
          ),
          const SizedBox(height: 12),

          // Refund Amount
          _buildDetailRow(
            icon: Icons.receipt_long_outlined,
            label: 'Refund Amount',
            value: '₹699',
          ),
          const SizedBox(height: 12),

          // Refunded to
          _buildDetailRow(
            icon: Icons.account_balance_outlined,
            label: 'Refunded to',
            value: 'UPI (Google Pay)  •••• 4321',
          ),
          const SizedBox(height: 12),

          // Transaction ID with Copy
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 16,
                color: Color(0xFF71717A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction ID',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71717A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          txnId,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _copyToClipboard(txnId, 'Transaction ID'),
                          child: const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Green Notification Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFBF2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Amount has been credited to your bank account. It may take 2-3 business days to reflect.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w500,
                      height: 1.25,
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

  // ── Return Details Card ───────────────────────────────────────
  Widget _buildReturnDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Return Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 14),

          // Return requested on
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Return requested on',
            value: 'Fri, 19 Jul, 2024 at 10:45 AM',
          ),
          const SizedBox(height: 12),

          // Pickup scheduled on
          _buildDetailRow(
            icon: Icons.local_shipping_outlined,
            label: 'Pickup scheduled on',
            value: 'Sat, 20 Jul, 2024\n(10:00 AM - 06:00 PM)',
          ),
          const SizedBox(height: 12),

          // Reason
          _buildDetailRow(
            icon: Icons.info_outline_rounded,
            label: 'Reason',
            value: 'Size issue',
          ),
        ],
      ),
    );
  }

  // ── Return Tracking Card (Vertical Stepper + Ola Maps route) ──
  Widget _buildReturnTrackingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Return Tracking',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 14),

          // 4-Step Vertical Tracker
          _buildReturnStepperItem(
            title: 'Pickup completed',
            subtitle: 'Sun, 21 Jul, 2024 at 01:30 PM',
            state: _StepperState.completed,
            isLast: false,
          ),
          _buildReturnStepperItem(
            title: 'At warehouse',
            subtitle: 'In transit to warehouse',
            state: _StepperState.active,
            isLast: false,
          ),
          _buildReturnStepperItem(
            title: 'Quality check',
            subtitle: 'Checking the returned item',
            state: _StepperState.pending,
            isLast: false,
          ),
          _buildReturnStepperItem(
            title: 'Refund process',
            subtitle: 'Refund will be initiated after quality check',
            state: _StepperState.pending,
            isLast: true,
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF4F4F6)),
          const SizedBox(height: 10),

          // Ola Maps Transit Link
          InkWell(
            onTap: () {
              context.push('/order-tracking', extra: _orderId);
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: const [
                Icon(
                  Icons.map_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Track Return Courier on Ola Maps',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnStepperItem({
    required String title,
    required String subtitle,
    required _StepperState state,
    required bool isLast,
  }) {
    Color circleColor;
    Widget circleChild;

    switch (state) {
      case _StepperState.completed:
        circleColor = const Color(0xFF2563EB);
        circleChild = const Icon(Icons.check_rounded, color: Colors.white, size: 12);
        break;
      case _StepperState.active:
        circleColor = const Color(0xFF2563EB);
        circleChild = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
        break;
      case _StepperState.pending:
        circleColor = const Color(0xFFE4E4E7);
        circleChild = const SizedBox();
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle & connecting line
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: state == _StepperState.pending ? Colors.white : circleColor,
                  shape: BoxShape.circle,
                  border: state == _StepperState.pending
                      ? Border.all(color: const Color(0xFFD4D4D8), width: 1.5)
                      : null,
                ),
                child: Center(child: circleChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: state == _StepperState.completed
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE4E4E7),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: state == _StepperState.pending
                          ? FontWeight.w600
                          : FontWeight.w800,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF71717A),
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

  // ── Product Details Card (Used by refunded, returnRequested, etc.)
  Widget _buildProductDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/jcosta_black_shirt.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: const Color(0xFFF4F4F6),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      color: Color(0xFF71717A),
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JCOSTA Men Solid Casual Black Shirt',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Size: M  •  Color: Black',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71717A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Text(
                          '₹699',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF18181B),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Qty: 1',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helper Row for Details ────────────────────────────────────
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF71717A),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. Bottom Action Bar
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    // Returning state in reference image has no bottom action buttons
    if (_currentStatus == OrderDetailStatus.returning) {
      return const SizedBox.shrink();
    }

    Widget content;

    switch (_currentStatus) {
      case OrderDetailStatus.delivered:
        // [Buy Again] (outlined) + [Return / Exchange] (filled)
        content = Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: () => _handleBuyAgain(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE61858), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Buy Again',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE61858),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    _changeStatus(OrderDetailStatus.returnRequested);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Return / Exchange request initiated.'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE61858),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Return / Exchange',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        break;

      case OrderDetailStatus.returnRequested:
        // [View Return Status] (outlined) + [Need Help] (filled)
        content = Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: () => _changeStatus(OrderDetailStatus.returning),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE61858), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'View Return Status',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE61858),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () => _showHelpDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE61858),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Need Help',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        break;

      case OrderDetailStatus.cancelled:
      case OrderDetailStatus.refunded:
      case OrderDetailStatus.returnRefunded:
      default:
        // Full width [Buy Again] (outlined)
        content = SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton(
            onPressed: () => _handleBuyAgain(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE61858), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Buy Again',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE61858),
              ),
            ),
          ),
        );
        break;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: content,
    );
  }

  void _handleBuyAgain(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to cart! Proceeding to cart...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push('/cart');
  }

  // ─────────────────────────────────────────────────────────────
  // Dialogs & Modals
  // ─────────────────────────────────────────────────────────────
  void _showHelpDialog(BuildContext context) {
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
                      'ModaRapp Support',
                      style: TextStyle(
                        fontSize: 17,
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
                ListTile(
                  leading: const Icon(Icons.chat_outlined, color: Color(0xFFE61858)),
                  title: const Text('Live Chat with Support Agent'),
                  subtitle: const Text('Available 24x7 for instant resolution'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connecting to live chat agent...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: Color(0xFFE61858)),
                  title: const Text('Call Helpline (Toll Free)'),
                  subtitle: const Text('1800-123-MODA (1800-123-6632)'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling ModaRapp Helpline...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Color(0xFFE61858)),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@modarapp.com'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening email support...')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStatusSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Order Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preview the screen dynamically for any product status:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                ),
                const SizedBox(height: 12),
                ...OrderDetailStatus.values.map((status) {
                  final isCurrent = _currentStatus == status;
                  String label;
                  IconData icon;
                  Color color;

                  switch (status) {
                    case OrderDetailStatus.delivered:
                      label = 'Delivered (Jul 17)';
                      icon = Icons.check_circle_rounded;
                      color = const Color(0xFF16A34A);
                      break;
                    case OrderDetailStatus.cancelled:
                      label = 'Cancelled (Jul 16)';
                      icon = Icons.cancel_rounded;
                      color = const Color(0xFFDC2626);
                      break;
                    case OrderDetailStatus.refunded:
                      label = 'Refunded - Variant 1 (Jul 20)';
                      icon = Icons.monetization_on_rounded;
                      color = const Color(0xFFD97706);
                      break;
                    case OrderDetailStatus.returnRequested:
                      label = 'Return Requested (Jul 19)';
                      icon = Icons.assignment_return_rounded;
                      color = const Color(0xFF9333EA);
                      break;
                    case OrderDetailStatus.returning:
                      label = 'Returning in Transit (Jul 21)';
                      icon = Icons.local_shipping_rounded;
                      color = const Color(0xFF2563EB);
                      break;
                    case OrderDetailStatus.returnRefunded:
                      label = 'Refunded Post-Return (Jul 24)';
                      icon = Icons.sync_rounded;
                      color = const Color(0xFF16A34A);
                      break;
                  }

                  return ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? color : const Color(0xFF18181B),
                      ),
                    ),
                    trailing: isCurrent
                        ? Icon(Icons.check_rounded, color: color, size: 20)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _changeStatus(status);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _StepperState {
  completed,
  active,
  pending,
}
