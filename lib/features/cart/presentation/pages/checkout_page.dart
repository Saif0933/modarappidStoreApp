import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/providers/products_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String _selectedPaymentMethod = 'Credit Card';

  final List<PaymentMethodOption> _paymentMethods = [
    PaymentMethodOption(id: 'cc', title: 'Credit Card', subtitle: 'Visa, MasterCard, Amex', icon: Icons.credit_card_rounded),
    PaymentMethodOption(id: 'paypal', title: 'PayPal', subtitle: 'Pay securely with your account', icon: Icons.account_balance_wallet_rounded),
    PaymentMethodOption(id: 'cod', title: 'Cash on Delivery', subtitle: 'Pay when your package arrives', icon: Icons.handshake_rounded),
  ];

  void _placeOrder() {
    final cartList = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    if (cartList.isEmpty) return;

    final totalAmount = cartNotifier.total;
    
    // Call order notifier
    ref.read(ordersProvider.notifier).placeOrder(cartList, totalAmount);
    
    // Capture details before clearing
    final mockOrderId = 'ORD-${10000 + ref.read(ordersProvider).length * 17}';
    
    // Clear Cart
    ref.read(cartProvider.notifier).clearCart();
    
    // Navigate to Success screen
    context.go('/order-success', extra: mockOrderId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedAddress = ref.watch(selectedAddressProvider);
    final cartList = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final subtotal = cartNotifier.subtotal;
    final tax = cartNotifier.tax;
    final shipping = cartNotifier.shipping;
    final total = cartNotifier.total;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: const CustomAppBar(title: 'Checkout'),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Delivery Address Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Address',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => context.push('/address-list'),
                          child: const Text('Change', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spaceM),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        boxShadow: AppConstants.lowShadow,
                      ),
                      child: selectedAddress == null
                          ? const Text('No delivery address selected. Tap "Change" to select or add one.')
                          : Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedAddress.name,
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedAddress.addressLine,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        selectedAddress.city,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedAddress.phone,
                                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Payment Methods
                    Text(
                      'Payment Method',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _paymentMethods.map((method) {
                        final isSelected = _selectedPaymentMethod == method.title;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: RadioListTile<String>(
                            value: method.title,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedPaymentMethod = val;
                                });
                              }
                            },
                            title: Text(
                              method.title,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              method.subtitle,
                              style: theme.textTheme.bodySmall,
                            ),
                            secondary: Icon(method.icon, color: AppColors.primary),
                            activeColor: AppColors.primary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 3. Order Summary Items
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spaceM),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartList.length,
                            itemBuilder: (context, index) {
                              final item = cartList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity}x ${item.product.title}',
                                        style: theme.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', theme),
                          const SizedBox(height: 6),
                          _buildSummaryRow('Delivery Charges', shipping == 0.0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}', theme),
                          const SizedBox(height: 6),
                          _buildSummaryRow('Est. Tax (5%)', '\$${tax.toStringAsFixed(2)}', theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Order Button
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Amount',
                        style: theme.textTheme.bodySmall,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Place Order',
                      onPressed: selectedAddress == null ? null : _placeOrder,
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

  Widget _buildSummaryRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class PaymentMethodOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  PaymentMethodOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
