import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple Auth state class
class AuthState {
  final bool isLoading;
  final String? error;
  final String? phoneNumber;
  final bool isOtpSent;
  final int otpTimer;

  AuthState({
    this.isLoading = false,
    this.error,
    this.phoneNumber,
    this.isOtpSent = false,
    this.otpTimer = 30,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? phoneNumber,
    bool? isOtpSent,
    int? otpTimer,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otpTimer: otpTimer ?? this.otpTimer,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());
  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(otpTimer: 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.otpTimer > 0) {
        state = state.copyWith(otpTimer: state.otpTimer - 1);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network request
    
    if (phoneNumber.length < 10) {
      state = state.copyWith(isLoading: false, error: 'Please enter a valid 10-digit phone number.');
      return false;
    }
    
    state = state.copyWith(
      isLoading: false,
      phoneNumber: phoneNumber,
      isOtpSent: true,
    );
    startTimer();
    return true;
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network request

    if (code.length < 6 || code != '123456') {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP. Enter "123456" to proceed.');
      return false;
    }

    state = state.copyWith(isLoading: false);
    return true;
  }

  void resendOtp() {
    if (state.otpTimer == 0) {
      startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
