import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(authProvider.notifier);
      final phone = '$_selectedCountryCode ${_phoneController.text.trim()}';
      final success = await notifier.sendOtp(_phoneController.text.trim());
      if (success) {
        if (mounted) {
          context.push('/otp', extra: phone);
        }
      } else {
        final error = ref.read(authProvider).error;
        if (mounted && error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Flipkart-style Top Banner (Gradient Header)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B3322), // Signature Deep Emerald
                    Color(0xFF041910), // Midnight Teal
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Atmospheric Glow
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.08),
                      ),
                    ),
                  ),
                  
                  // Main Banner Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          const SizedBox(height: 24),
                          // Small Branded Logo
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0E7F53), Color(0xFF074D32)],
                              ),
                              border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0E7F53).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.local_mall_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          )
                              .animate()
                              .scale(duration: 600.ms, curve: Curves.easeOutBack)
                              .then(delay: 200.ms)
                              .shimmer(duration: 1000.ms),

                          const SizedBox(height: 16),

                          // Brand Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'MODAR',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                'APPID',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amber,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fade(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0.0),

                          const SizedBox(height: 6),

                          // Page Tagline
                          Text(
                            'SIGN IN / REGISTER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 2.0,
                            ),
                          )
                              .animate()
                              .fade(duration: 600.ms, delay: 350.ms),
                      ],
                    ),
                  ),

                  // Floating Back Button
                  if (Navigator.canPop(context))
                    Positioned(
                      top: 16 + MediaQuery.of(context).padding.top,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Form Section
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading Inside Form
                    Text(
                      'Welcome to ModarApp',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Enter your mobile number to sign in or create an account.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 450.ms),
                    
                    const SizedBox(height: 36),

                    // Phone Input Field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Code Selector
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              items: const [
                                DropdownMenuItem(value: '+1', child: Text('+1')),
                                DropdownMenuItem(value: '+91', child: Text('+91')),
                                DropdownMenuItem(value: '+44', child: Text('+44')),
                                DropdownMenuItem(value: '+971', child: Text('+971')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCountryCode = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Actual Input Field
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            hintText: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (val.length < 10) {
                                return 'Enter a valid 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 500.ms)
                        .slideY(begin: 0.1, end: 0.0),
                    
                    const SizedBox(height: 28),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Continue',
                        isLoading: authState.isLoading,
                        onPressed: _submit,
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 550.ms),

                    const SizedBox(height: 48),

                    // Bottom Trust Badge
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '256-bit SSL secure checkout',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 600.ms),

                    const SizedBox(height: 24),

                    // Bottom Disclaimer
                    Center(
                      child: Text(
                        'By continuing, you agree to our\nTerms & Conditions and Privacy Policy.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 650.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
