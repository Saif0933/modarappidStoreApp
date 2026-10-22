import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/splash_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // Fallback timer to guarantee redirection to /login even if provider completes early/late
    _fallbackTimer = Timer(const Duration(milliseconds: 2700), () {
      _navigateToLogin();
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _navigateToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to initialization provider for redirection to login screen
    ref.listen<AsyncValue<bool>>(splashInitProvider, (previous, next) {
      if (next.hasValue && next.value == true) {
        _navigateToLogin();
      }
    });

    final splashState = ref.watch(splashInitProvider);
    if (splashState.hasValue && splashState.value == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToLogin();
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7EFE7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7EFE7),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Exact splash screen matching user provided design
            Image.asset(
              'assets/images/splash_screen.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
                .animate()
                .fade(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(1.02, 1.02),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                ),
          ],
        ),
      ),
    );
  }
}
