import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../../../core/widgets/quantity_selector.dart';
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

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(double subtotal) {
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'SAVE20') {
      HapticFeedback.mediumImpact();
      setState(() {
        _couponApplied = true;
        _couponDiscount = subtotal * 0.20; // 20% discount
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coupon SAVE20 applied! 20% discount added.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Coupon Code! Try "SAVE20".'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWideTablet = context.screenWidth >= 800;

    // Watch cart state
    final cartList = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    // Empty Cart View
    if (cartList.isEmpty) {
      final recommendedProducts = ref
          .watch(productsProvider)
          .where((p) => p.isTrending || p.isPopular)
          .take(3)
          .toList();

      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceM,
              vertical: AppConstants.spaceM,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    EmptyWidget(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your Cart is Empty',
                      description:
                          'Looks like you haven\'t added any items yet. Explore our fashion collection and find items tailored for you.',
                      buttonText: 'Start Shopping',
                      onButtonPressed: () => context.go('/home'),
                    ),
                    if (recommendedProducts.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommended For You',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...recommendedProducts.map(
                        (product) => _buildRecommendedItemTile(product, isDark, theme),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final subtotal = cartNotifier.subtotal;
    final tax = cartNotifier.tax;
    final shipping = cartNotifier.shipping;
    final discount = _couponApplied ? _couponDiscount : 0.0;
    final total = (subtotal + tax + shipping - discount).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          'My Cart (${cartList.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Clear Cart',
            icon: const Icon(Icons.delete_sweep_outlined, size: 22),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Cart?'),
                  content: const Text('Are you sure you want to remove all items from your cart?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(cartProvider.notifier).clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cart cleared.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isWideTablet
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Cart items list
                        Expanded(
                          flex: 6,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: cartList.length,
                            itemBuilder: (context, index) {
                              return _buildCartItemTile(cartList[index], isDark, theme);
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right: Order summary card
                        SizedBox(
                          width: (context.screenWidth * 0.38).clamp(320.0, 390.0),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _buildSummaryCard(
                              subtotal: subtotal,
                              tax: tax,
                              shipping: shipping,
                              discount: discount,
                              total: total,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM,
                        vertical: AppConstants.spaceS,
                      ),
                      children: [
                        // Items list
                        ...cartList.map(
                          (item) => _buildCartItemTile(item, isDark, theme),
                        ),
                        const SizedBox(height: 8),

                        // Promo code card inside scroll view
                        _buildPromoCodeCard(subtotal, isDark, theme),
                        const SizedBox(height: 16),

                        // Bill breakdown card inside scroll view
                        _buildBillDetailsCard(
                          subtotal: subtotal,
                          discount: discount,
                          shipping: shipping,
                          tax: tax,
                          total: total,
                          isDark: isDark,
                          theme: theme,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Compact mobile sticky checkout bar
                  _buildMobileBottomCheckoutBar(total, isDark, theme),
                ],
              ),
      ),
    );
  }

  Widget _buildCartItemTile(CartItem item, bool isDark, ThemeData theme) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_sweep_rounded, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        ref.read(cartProvider.notifier).removeFromCart(item.product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.title} removed from cart.'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: AppConstants.lowShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded border container
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : AppColors.bgLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: NetworkImageWidget(
                imageUrl: item.product.imageUrl,
                width: 76,
                height: 76,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size/Qty: ${item.product.weight}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '\$${item.product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.product.originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '\$${item.product.originalPrice!.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Quantity selector and delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(cartProvider.notifier).removeFromCart(item.product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.product.title} removed from cart.'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 10),
                QuantitySelector(
                  quantity: item.quantity,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    ref.read(cartProvider.notifier).updateQuantity(item.product.id, val);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedItemTile(Product product, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppConstants.lowShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            child: NetworkImageWidget(
              imageUrl: product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
            label: const Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(cartProvider.notifier).addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title} added to cart!'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeCard(double subtotal, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppConstants.lowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.discount_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Apply Promo Code',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon (SAVE20)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  onPressed: () => _applyCoupon(subtotal),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          if (_couponApplied) ...[
            const SizedBox(height: 8),
            Text(
              'SAVE20 Active - 20% Discount applied!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillDetailsCard({
    required double subtotal,
    required double discount,
    required double shipping,
    required double tax,
    required double total,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppConstants.lowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Breakdown',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', theme, isDark),
          const SizedBox(height: 8),
          if (_couponApplied) ...[
            _buildPriceRow(
              'Discount (20%)',
              '-\$${discount.toStringAsFixed(2)}',
              theme,
              isDark,
              textCol: AppColors.accent,
            ),
            const SizedBox(height: 8),
          ],
          _buildPriceRow(
            'Delivery Fee',
            shipping == 0.0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
            theme,
            isDark,
            textCol: shipping == 0.0 ? AppColors.success : null,
          ),
          const SizedBox(height: 8),
          _buildPriceRow('Est. Tax (5%)', '\$${tax.toStringAsFixed(2)}', theme, isDark),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total Payable',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomCheckoutBar(double total, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Payable',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              elevation: 2,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.push('/checkout');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Checkout Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double subtotal,
    required double tax,
    required double shipping,
    required double discount,
    required double total,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: AppConstants.mediumShadow,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Promo Code Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon (SAVE20)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  onPressed: () => _applyCoupon(subtotal),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          if (_couponApplied) ...[
            const SizedBox(height: 8),
            Text(
              'SAVE20 Active - 20% Discount applied!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Pricing Calculations Block
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', theme, isDark),
          const SizedBox(height: 8),
          if (_couponApplied) ...[
            _buildPriceRow(
              'Discount (20%)',
              '-\$${discount.toStringAsFixed(2)}',
              theme,
              isDark,
              textCol: AppColors.accent,
            ),
            const SizedBox(height: 8),
          ],
          _buildPriceRow(
            'Delivery Fee',
            shipping == 0.0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
            theme,
            isDark,
            textCol: shipping == 0.0 ? AppColors.success : null,
          ),
          const SizedBox(height: 8),
          _buildPriceRow('Est. Tax (5%)', '\$${tax.toStringAsFixed(2)}', theme, isDark),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Divider(height: 1),
          ),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total Amount',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Checkout Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              elevation: 2,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.push('/checkout');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Checkout Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trust signals underneath
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '100% Secure Checkout & Guarantee',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, ThemeData theme, bool isDark, {Color? textCol}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textCol ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
