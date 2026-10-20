import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'network_image_widget.dart';

/// Minimalist fashion product card matching Flipkart / Shopsy suggested items screenshot.
/// Responsive on both phone and tablet.
class SuggestedProductCard extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double? bankOfferPrice;
  final VoidCallback onTap;

  const SuggestedProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.bankOfferPrice,
    required this.onTap,
  });

  /// Formats amount in standard Indian Rupee format, e.g. ₹2,499, ₹449
  static String formatRupee(num amount) {
    final int value = amount.round();
    final String str = value.toString();
    if (str.length <= 3) return '₹$str';

    final String lastThree = str.substring(str.length - 3);
    final String otherNumbers = str.substring(0, str.length - 3);
    final StringBuffer formatted = StringBuffer();
    for (int i = 0; i < otherNumbers.length; i++) {
      if (i > 0 && (otherNumbers.length - i) % 2 == 0) {
        formatted.write(',');
      }
      formatted.write(otherNumbers[i]);
    }
    formatted.write(',');
    formatted.write(lastThree);
    return '₹${formatted.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Responsive font scaling
    final titleSize = Responsive.value<double>(context, phone: 12.5, tablet: 14.0);
    final priceSize = Responsive.value<double>(context, phone: 13.0, tablet: 14.5);
    final originalPriceSize = Responsive.value<double>(context, phone: 11.5, tablet: 13.0);
    final bankOfferSize = Responsive.value<double>(context, phone: 10.5, tablet: 12.0);

    // Calculate effective bank offer if applicable
    final double? effectiveBankOffer = bankOfferPrice ??
        ((price >= 1500 && originalPrice != null && originalPrice! > price)
            ? (price * 0.9).roundToDouble()
            : null);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Fashion Product Image with smooth rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: AspectRatio(
              aspectRatio: 0.82,
              child: NetworkImageWidget(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 5),

          // 2. Product Title (1 line with ellipsis matching screenshot)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
              color: isDark ? Colors.white : const Color(0xFF212121),
            ),
          ),

          const SizedBox(height: 2),

          // 3. Price Row: Strikethrough Original Price + Bold Selling Price
          Row(
            children: [
              if (originalPrice != null && originalPrice! > price) ...[
                Text(
                  formatRupee(originalPrice!),
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF757575),
                    fontSize: originalPriceSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                formatRupee(price),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: priceSize,
                  color: isDark ? Colors.white : const Color(0xFF212121),
                ),
              ),
            ],
          ),

          // 4. Bank Offer Row (Crisp blue text matching screenshot)
          if (effectiveBankOffer != null) ...[
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${formatRupee(effectiveBankOffer)} ',
                    style: TextStyle(
                      color: const Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                      fontSize: bankOfferSize,
                    ),
                  ),
                  TextSpan(
                    text: 'with Bank offer',
                    style: TextStyle(
                      color: const Color(0xFF1565C0),
                      fontSize: bankOfferSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
