import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';

class OrderSuccessPage extends StatelessWidget {
  final String orderId;

  const OrderSuccessPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Animation Ring
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceXL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1000.ms),

              const SizedBox(height: 32),

              // Title
              Text(
                'Order Placed Successfully!',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fade(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0.0),

              const SizedBox(height: 12),

              // Description
              Text(
                'Thank you for your purchase. We have received your order and are preparing it for shipment.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fade(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 24),

              // Order ID Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Order ID: ',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      orderId,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fade(duration: 400.ms, delay: 400.ms)
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),

              const Spacer(),

              // Primary Actions
              PrimaryButton(
                text: 'Continue Shopping',
                onPressed: () => context.go('/home'),
              )
                  .animate()
                  .fade(duration: 400.ms, delay: 500.ms),
              const SizedBox(height: 12),
              
              // Secondary View Order Status
              SecondaryButton(
                text: 'Track Order',
                onPressed: () => context.go('/order-tracking'),
              )
                  .animate()
                  .fade(duration: 400.ms, delay: 600.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
