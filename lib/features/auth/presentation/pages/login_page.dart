import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final String _selectedCountryCode = '+91';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Mobile number is required';
      });
      return;
    }
    if (rawPhone.length < 10) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    final notifier = ref.read(authProvider.notifier);
    final phone = '$_selectedCountryCode $rawPhone';
    final success = await notifier.sendOtp(rawPhone);
    if (success && mounted) {
      context.push('/otp', extra: phone);
    } else {
      final error = ref.read(authProvider).error;
      if (mounted && error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFE61858),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _signInWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In will be available soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildIndianFlag() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 26,
        height: 17,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFFFF9933))),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF000080),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: Container(color: const Color(0xFF138808))),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.46).clamp(310.0, 440.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F5F0),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Top Hero Banner (Matching the Design Image)
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: heroHeight,
                        child: Image.asset(
                          'assets/images/login_hero.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),

                      // Optional Floating Back Button
                      if (Navigator.canPop(context))
                        Positioned(
                          top: 14 + MediaQuery.of(context).padding.top,
                          left: 14,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withValues(alpha: 0.85),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF18181B),
                                size: 16,
                              ),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // 2. White Bottom Sheet Form Card
                  Transform.translate(
                    offset: const Offset(0, -26),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Handle Pill Indicator
                          Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3D7DF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Title: Login to ModaRapp
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF18181B),
                                letterSpacing: -0.3,
                              ),
                              children: [
                                TextSpan(text: 'Login to Moda'),
                                TextSpan(
                                  text: 'Rapp',
                                  style: TextStyle(
                                    color: Color(0xFFE61858),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 150.ms),

                          const SizedBox(height: 6),

                          // Subtitle
                          const Text(
                            'Enter your mobile number to continue',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF71717A),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 200.ms),

                          const SizedBox(height: 22),

                          // Mobile Number Input Box
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _hasError
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildIndianFlag(),
                                const SizedBox(width: 8),
                                const Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF18181B),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: Color(0xFF71717A),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: const Color(0xFFE5E7EB),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    buildCounter: (
                                      context, {
                                      required currentLength,
                                      required isFocused,
                                      maxLength,
                                    }) =>
                                        null,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF18181B),
                                      letterSpacing: 0.5,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter mobile number',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      if (_hasError) {
                                        setState(() => _hasError = false);
                                      }
                                    },
                                    onSubmitted: (_) => _submit(),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 250.ms),

                          if (_hasError && _errorMessage != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 18),

                          // Send OTP Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE61858),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE61858)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(26),
                                onTap: authState.isLoading ? null : _submit,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Spacer(),
                                      if (authState.isLoading)
                                        const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      else ...[
                                        const Text(
                                          'Send OTP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 300.ms),

                          const SizedBox(height: 20),

                          // OR Divider
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Color(0xFFE5E7EB),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Color(0xFFE5E7EB),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 350.ms),

                          const SizedBox(height: 20),

                          // Continue with Google Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(26),
                                onTap: _signInWithGoogle,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildGoogleIcon(),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Color(0xFF18181B),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 400.ms),

                          const SizedBox(height: 26),

                          // Terms and Conditions Disclaimer
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF71717A),
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                    text: 'By continuing, you agree to our\n'),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: const TextStyle(
                                    color: Color(0xFFE61858),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xFFE61858),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 450.ms),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Google 4 colored segments
    canvas.drawArc(rect, -0.6, -1.8, false, redPaint);
    canvas.drawArc(rect, -2.4, -1.2, false, yellowPaint);
    canvas.drawArc(rect, 0.6, 1.8, false, greenPaint);
    canvas.drawArc(rect, 0.0, 0.6, false, bluePaint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTRB(w * 0.45, h * 0.38, w * 0.98, h * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
