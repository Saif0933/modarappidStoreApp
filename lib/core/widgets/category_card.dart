import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData getCategoryIcon(String name) {
      final key = name.toLowerCase();
      if (key.contains('jacket')) return Icons.checkroom_rounded;
      if (key.contains('hoodie')) return Icons.checkroom_rounded;
      if (key.contains('jeans') || key.contains('denim') || key.contains('pant')) return Icons.dry_cleaning_rounded;
      if (key.contains('footwear') || key.contains('shoe') || key.contains('sneaker')) return Icons.directions_run_rounded;
      if (key.contains('dress')) return Icons.woman_rounded;
      if (key.contains('accessory') || key.contains('sunglass') || key.contains('watch')) return Icons.watch_rounded;
      if (key.contains('t-shirt') || key.contains('shirt')) return Icons.checkroom_rounded;
      return Icons.shopping_bag_rounded;
    }

    final bg = backgroundColor ?? 
        (isDark 
            ? AppColors.primary.withOpacity(0.15) 
            : AppColors.primary.withOpacity(0.08));

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: imagePath.startsWith('http')
                  ? ClipOval(
                      child: Image.network(
                        imagePath,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          getCategoryIcon(title),
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      getCategoryIcon(title),
                      size: 32,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
