import 'package:flutter/material.dart';
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
  String _selectedCountryCode = '+1';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Back Button if pop is possible
              if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),

              const Spacer(),

              // Welcome Title
              Text(
                'Welcome to ModarApp',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Enter your mobile number to sign in or create an account.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Phone Number text field with inline country code
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Code Selector
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        const SizedBox(width: 8),

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
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Continue Button
                    PrimaryButton(
                      text: 'Continue',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Disclaimer
              Align(
                alignment: Alignment.center,
                child: Text(
                  'By continuing, you agree to our Terms & Conditions and Privacy Policy.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
