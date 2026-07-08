import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'Arabic',
    'French',
    'German',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch Theme Mode
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: const CustomAppBar(title: 'Settings'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Theme Configuration Row
              _buildSectionTitle('Theme & Styling', theme),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: SwitchListTile(
                  secondary: Icon(
                    currentThemeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Dark Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    currentThemeMode == ThemeMode.dark ? 'Dark UI theme is active' : 'Light UI theme is active',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: currentThemeMode == ThemeMode.dark,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state =
                        val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 2. Language Selection Block
              _buildSectionTitle('App Localization', theme),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      items: _languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang, style: theme.textTheme.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedLanguage = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Information & Legal Policies
              _buildSectionTitle('Legal & Support', theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // About Us
                      ExpansionTile(
                        leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        title: const Text('About ModarApp Store', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'ModarApp Store is a premium fashion e-commerce application designed to offer the finest selected jackets, hoodies, denim jeans, dresses, footwear, and accessories from handpicked global brands. Built with modern design systems and performance in mind.',
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                      _buildDivider(isDark),

                      // Privacy Policy
                      ExpansionTile(
                        leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'We value your privacy. ModarApp collects location coordinates to pinpoint delivery addresses and billing details to authorize payments safely. We do not sell or lease user contact data to any third-party advertising network.',
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                      _buildDivider(isDark),

                      // Terms & Conditions
                      ExpansionTile(
                        leading: const Icon(Icons.gavel_rounded, color: AppColors.primary),
                        title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Users agree to utilize this application in compliance with local rules. Prices displayed fluctuate based on fresh market changes. Refund requests are subject to verification within 24 hours of delivery receipt.',
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceM, 16, AppConstants.spaceM, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
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
