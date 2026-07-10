import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Premium Header with Gradient & Decorative shapes
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient Container
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0E7F53), // Signature Emerald
                        Color(0xFF074D32), // Deep Forest Green
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0E7F53).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),

                // Decorative atmospheric glow orbs
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: -20,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.04),
                  ),
                ),

                // Top Navigation/Title row
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceM,
                      vertical: AppConstants.spaceS,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Profile',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push('/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // User details layout
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 35,
                  child: Row(
                    children: [
                      // Avatar block with custom camera overlay badge
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/edit-profile');
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Hero(
                              tag: 'profile_avatar',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 44,
                                    backgroundColor: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primaryLight,
                                    child: Text(
                                      user.name
                                          .split(' ')
                                          .map((n) => n.isNotEmpty ? n[0] : '')
                                          .join(),
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: isDark ? Colors.white : AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // User text info + Premium Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'GOLD MEMBER',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms).slideY(
                  begin: -0.15,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),

            // 2. Floating Stats Card
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: AppConstants.highShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.local_shipping_outlined,
                        iconColor: AppColors.primary,
                        count: '12',
                        label: 'Orders',
                        onTap: () => context.push('/order-history'),
                        theme: theme,
                      ),
                      _buildStatDivider(isDark),
                      _buildStatItem(
                        icon: Icons.favorite_border_rounded,
                        iconColor: const Color(0xFFEF4444),
                        count: '5',
                        label: 'Wishlist',
                        onTap: () => context.go('/wishlist'),
                        theme: theme,
                      ),
                      _buildStatDivider(isDark),
                      _buildStatItem(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        count: '2',
                        label: 'Addresses',
                        onTap: () => context.push('/address-list'),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(
                    begin: const Offset(0.92, 0.92),
                    curve: Curves.easeOutBack,
                  ),
            ),

            // 3. Account Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
              child: Text(
                'ACCOUNT SETTINGS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 180.ms),
            const SizedBox(height: 12),

            // Menu Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: AppConstants.lowShadow,
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryLight.withOpacity(isDark ? 0.15 : 0.8),
                      title: 'Edit Profile',
                      subtitle: 'Change name, email and phone number',
                      onTap: () => context.push('/edit-profile'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.shopping_bag_rounded,
                      iconColor: AppColors.accent,
                      iconBgColor: AppColors.accentLight.withOpacity(isDark ? 0.15 : 0.8),
                      title: 'My Orders',
                      subtitle: 'View, track or cancel your orders',
                      onTap: () => context.push('/order-history'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFFEE2E2).withOpacity(isDark ? 0.15 : 0.8),
                      title: 'My Wishlist',
                      subtitle: 'Find all your saved and favorited products',
                      onTap: () => context.go('/wishlist'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      iconBgColor: const Color(0xFFDBEAFE).withOpacity(isDark ? 0.15 : 0.8),
                      title: 'Shipping Addresses',
                      subtitle: 'Manage your saved delivery addresses',
                      onTap: () => context.push('/address-list'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.settings_rounded,
                      iconColor: const Color(0xFF6B7280),
                      iconBgColor: const Color(0xFFF3F4F6).withOpacity(isDark ? 0.15 : 0.8),
                      title: 'Settings',
                      subtitle: 'Configure application preferences and themes',
                      onTap: () => context.push('/settings'),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 240.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),
            const SizedBox(height: 24),

            // 4. Action Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
              child: Text(
                'ACCOUNT ACTIONS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 12),

            // Logout card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  border: Border.all(
                    color: Colors.red.withOpacity(isDark ? 0.25 : 0.15),
                  ),
                  boxShadow: AppConstants.lowShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      _showLogoutDialog(context, theme, isDark);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout Account',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Safely sign out of your account',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 350.ms).slideY(
                  begin: 0.15,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      indent: 16,
      endIndent: 16,
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          elevation: 16,
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 20),
                Text(
                  'Logout Account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to log out of your account? You will need to sign in again to access your orders and wishlist.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                          context.go('/login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
