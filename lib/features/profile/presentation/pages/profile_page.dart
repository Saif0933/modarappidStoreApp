import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';

// User Details Provider
class UserProfile {
  final String name;
  final String email;
  final String phone;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  UserProfile copyWith({String? name, String? email, String? phone}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(UserProfile(
          name: 'Saif Al-Islam',
          email: 'saif.al.islam@example.com',
          phone: '+1 234-567-8910',
        ));

  void updateProfile(String name, String email, String phone) {
    state = UserProfile(name: name, email: email, phone: phone);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Header Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceL),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: AppConstants.mediumShadow,
                  ),
                  child: Row(
                    children: [
                      // Avatar placeholder
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          user.name.split(' ').map((n) => n[0]).join(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // User info details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phone,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Menu Options Block
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        onTap: () => context.push('/edit-profile'),
                        theme: theme,
                      ),
                      _buildDivider(isDark),
                      _buildMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'My Orders',
                        onTap: () => context.push('/order-history'),
                        theme: theme,
                      ),
                      _buildDivider(isDark),
                      _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'My Wishlist',
                        onTap: () => context.go('/wishlist'),
                        theme: theme,
                      ),
                      _buildDivider(isDark),
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Shipping Addresses',
                        onTap: () => context.push('/address-list'),
                        theme: theme,
                      ),
                      _buildDivider(isDark),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => context.push('/settings'),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logout Row Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: Text(
                      'Logout Account',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.redAccent),
                    onTap: () {
                      // Redirect back to login
                      context.go('/login');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedLight),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      indent: 16,
      endIndent: 16,
    );
  }
}
