import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/responsive.dart';
import 'network_image_widget.dart';

/// Product card matching the exact Flipkart 2-column feed screenshot.
/// Features:
/// - Clean rounded image container
/// - Optional top-left badge (e.g. "Lowest price live")
/// - Optional bottom-left rating pill (e.g. "4.7 ★ (1,600)")
/// - Bold Brand + Regular Title in single line
/// - Strikethrough original price + Bold current price
/// - Optional blue "with Bank offer" row
class FeedProductCard extends StatelessWidget {
  final String id;
  final String? brand;
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double? bankOfferPrice;
  final double rating;
  final int reviewsCount;
  final String? badgeText;
  final bool showRatingPill;
  final bool hasGreyBackground;
  final VoidCallback onTap;

  const FeedProductCard({
    super.key,
    required this.id,
    this.brand,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.bankOfferPrice,
    required this.rating,
    required this.reviewsCount,
    this.badgeText,
    this.showRatingPill = false,
    this.hasGreyBackground = false,
    required this.onTap,
  });

  /// Formats amount in standard Indian Rupee format, e.g. ₹763, ₹79,900
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final brandSize = Responsive.value<double>(context, phone: 13.0, tablet: 14.5);
    final titleSize = Responsive.value<double>(context, phone: 12.0, tablet: 13.5);
    final priceSize = Responsive.value<double>(context, phone: 14.0, tablet: 15.5);
    final originalPriceSize = Responsive.value<double>(context, phone: 12.0, tablet: 13.0);
    final bankOfferSize = Responsive.value<double>(context, phone: 11.5, tablet: 12.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Image Container with Badges
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: hasGreyBackground ? 0.95 : 0.85,
              child: Container(
                color: hasGreyBackground
                    ? (isDark ? AppColors.surfaceDark : const Color(0xFFF1F3F5))
                    : (isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC)),
                child: Stack(
                  children: [
                    // Product Image
                    Positioned.fill(
                      child: NetworkImageWidget(
                        imageUrl: imageUrl,
                        fit: hasGreyBackground ? BoxFit.contain : BoxFit.cover,
                      ),
                    ),

                    // Top-Left Badge (e.g. "Lowest price live")
                    if (badgeText != null && badgeText!.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF28246E), // Dark purple from screenshot
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),

                    // Bottom-Left Rating Pill (e.g. "4.7 ★ (1,600)")
                    if (showRatingPill)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Color(0xFF16A34A), // Green star
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '(${reviewsCount >= 1000 ? "${(reviewsCount / 1000).toStringAsFixed(1)}k" : reviewsCount})',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          // 2. Brand & Title (Single Line with Ellipsis)
          Text.rich(
            TextSpan(
              children: [
                if (brand != null && brand!.isNotEmpty) ...[
                  TextSpan(
                    text: '$brand ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: brandSize,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontWeight: brand != null ? FontWeight.normal : FontWeight.w500,
                    fontSize: titleSize,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 3),

          // 3. Price Row: Strikethrough Original + Bold Current
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (originalPrice != null && originalPrice! > price) ...[
                Text(
                  formatRupee(originalPrice!),
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontSize: originalPriceSize,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                formatRupee(price),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: priceSize,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),

          // 4. Bank Offer Row (Blue text from screenshot)
          if (bankOfferPrice != null) ...[
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${formatRupee(bankOfferPrice!)} ',
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: bankOfferSize,
                    ),
                  ),
                  TextSpan(
                    text: 'with Bank offer',
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
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
