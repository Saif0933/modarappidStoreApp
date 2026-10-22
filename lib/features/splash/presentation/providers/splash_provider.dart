import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashInitProvider = FutureProvider<bool>((ref) async {
  // Simulate initialization and loading delay for splash screen
  await Future.delayed(const Duration(milliseconds: 2500));
  return true;
});
