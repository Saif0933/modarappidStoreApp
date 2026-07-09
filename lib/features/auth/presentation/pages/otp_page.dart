import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verify() async {
    final code = _getOtpCode();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit OTP code.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(code);
    if (success) {
      if (mounted) {
        context.go('/home');
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

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verify(); // Auto-verify on final digit entry
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
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
                    right: -50,
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
                            'SECURE OTP VERIFICATION',
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

            // 2. OTP Input & Control Section
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Header Text
                  Text(
                    'Verify Account',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 400.ms),
                  const SizedBox(height: 8),

                  RichText(
                    text: TextSpan(
                      text: 'We sent a 6-digit verification code to ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      children: [
                        TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 450.ms),

                  const SizedBox(height: 36),

                  // 6-digit OTP Cells Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) {
                        final cellWidth = (MediaQuery.of(context).size.width - 56 - 50) / 6;
                        return SizedBox(
                          width: cellWidth > 48 ? 48 : cellWidth,
                          height: 54,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => _onOtpDigitChanged(index, val),
                          ),
                        );
                      },
                    ),
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 500.ms)
                      .slideY(begin: 0.1, end: 0.0),

                  const SizedBox(height: 24),

                  // Resend Timer Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            authState.otpTimer > 0 
                                ? 'Resend code in 0:${authState.otpTimer.toString().padLeft(2, '0')}'
                                : 'Did not receive code?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      if (authState.otpTimer == 0)
                        TextButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).resendOtp();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('OTP Code resent successfully.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text(
                            'Resend OTP',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 550.ms),

                  const SizedBox(height: 36),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Verify Code',
                      isLoading: authState.isLoading,
                      onPressed: _verify,
                    ),
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 600.ms),

                  const SizedBox(height: 48),

                  // Secure checkout trust badge
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Encrypted verification connection',
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
                      .fade(duration: 600.ms, delay: 650.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
