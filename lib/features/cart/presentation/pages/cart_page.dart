import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
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
    
    // Watch cart state
    final cartList = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cartList.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: EmptyWidget(
          icon: Icons.shopping_cart_outlined,
          title: 'Your Cart is Empty',
          description: 'Looks like you haven\'t added any items to your cart yet.',
          buttonText: 'Start Shopping',
          onButtonPressed: () => context.go('/home'),
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
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cart Items Scrollable List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM, vertical: AppConstants.spaceS),
                physics: const BouncingScrollPhysics(),
                itemCount: cartList.length,
                itemBuilder: (context, index) {
                  final item = cartList[index];
                  return Container(
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
                        // Image
                        NetworkImageWidget(
                          imageUrl: item.product.imageUrl,
                          width: 80,
                          height: 80,
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),

                        // Details Block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                item.product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Weight/Size details
                              Text(
                                item.product.weight,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Price Details
                              Text(
                                '\$${item.product.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Updater & Delete Row
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              onPressed: () {
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
                            const SizedBox(height: 12),
                            // Counter
                            QuantitySelector(
                              quantity: item.quantity,
                              onChanged: (val) {
                                ref.read(cartProvider.notifier).updateQuantity(item.product.id, val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Coupon Code & Price Summary Drawer Page Block
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
                boxShadow: AppConstants.mediumShadow,
                border: Border(
                  top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                          ),
                          onPressed: () => _applyCoupon(subtotal),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pricing Calculations Block
                  _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', theme, isDark),
                  const SizedBox(height: 6),
                  if (_couponApplied) ...[
                    _buildPriceRow('Discount (20%)', '-\$${discount.toStringAsFixed(2)}', theme, isDark, textCol: AppColors.accent),
                    const SizedBox(height: 6),
                  ],
                  _buildPriceRow('Delivery Fee', shipping == 0.0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}', theme, isDark, textCol: shipping == 0.0 ? AppColors.success : null),
                  const SizedBox(height: 6),
                  _buildPriceRow('Est. Tax (5%)', '\$${tax.toStringAsFixed(2)}', theme, isDark),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),

                  // Total Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkout Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                    ),
                    onPressed: () => context.push('/checkout'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Checkout Now',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, ThemeData theme, bool isDark, {Color? textCol}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
