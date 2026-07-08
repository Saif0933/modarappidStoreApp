import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingWidget({
    super.key,
    this.size = 40.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.light
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
