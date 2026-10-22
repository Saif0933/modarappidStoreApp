import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  // Pre-fill 1, 2, 3, 4, 5, 6 as shown in the design image
  final List<TextEditingController> _controllers = [
    TextEditingController(text: '1'),
    TextEditingController(text: '2'),
    TextEditingController(text: '3'),
    TextEditingController(text: '4'),
    TextEditingController(text: '5'),
    TextEditingController(text: '6'),
  ];
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 28;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 28);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
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
          content: Text('Please enter all 6 digits of the OTP code.'),
          backgroundColor: Color(0xFFE61858),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(code);
    if (success && mounted) {
      context.go('/home');
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

  void _resendCode() {
    if (_countdown > 0) return;
    ref.read(authProvider.notifier).resendOtp();
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new OTP has been sent.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onDigitChanged(int index, String val) {
    if (val.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  Widget _buildOtpBox(int index) {
    final hasFocus = _focusNodes[index].hasFocus;
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus ? const Color(0xFFE61858) : const Color(0xFFE5E7EB),
          width: hasFocus ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                _controllers[index].text.isEmpty &&
                index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) =>
                null,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF18181B),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (val) => _onDigitChanged(index, val),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayPhone = widget.phoneNumber.isNotEmpty
        ? widget.phoneNumber
        : '+91 98765 43210';
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.44).clamp(300.0, 420.0);

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
                  // 1. Top Hero Section matching user design
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: heroHeight,
                        child: Image.asset(
                          'assets/images/otp_hero.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),

                      // Interactive Back Button positioned at top-left
                      Positioned(
                        top: 12 + MediaQuery.of(context).padding.top,
                        left: 14,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: 0.85),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF18181B),
                              size: 20,
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

                          // Title: Enter OTP
                          const Text(
                            'Enter OTP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF18181B),
                              letterSpacing: -0.3,
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 150.ms),

                          const SizedBox(height: 6),

                          // Subtitle with phone number
                          Text(
                            'Please enter the 6-digit code sent to',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF71717A),
                              fontWeight: FontWeight.w400,
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 200.ms),

                          const SizedBox(height: 2),

                          Text(
                            displayPhone,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
                              letterSpacing: 0.2,
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 220.ms),

                          const SizedBox(height: 24),

                          // 6 OTP Input Boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => _buildOtpBox(index),
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 250.ms),

                          const SizedBox(height: 22),

                          // Resend Code Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Didn’t receive the code? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF71717A),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              GestureDetector(
                                onTap: _countdown == 0 ? _resendCode : null,
                                child: Text(
                                  _countdown > 0
                                      ? 'Resend OTP (00:${_countdown.toString().padLeft(2, '0')})'
                                      : 'Resend OTP',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFFE61858),
                                    fontWeight: _countdown == 0
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 300.ms),

                          const SizedBox(height: 26),

                          // Verify & Continue Button
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
                                onTap: authState.isLoading ? null : _verify,
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
                                          'Verify & Continue',
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
                              .fade(duration: 500.ms, delay: 350.ms),

                          const SizedBox(height: 28),

                          // Privacy / Security Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDE8ED),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.shield_outlined,
                                    color: Color(0xFFE61858),
                                    size: 19,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your number is safe with us.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF71717A),
                                      height: 1.3,
                                    ),
                                  ),
                                  Text(
                                    'We never share it with anyone.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF71717A),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 400.ms),

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
