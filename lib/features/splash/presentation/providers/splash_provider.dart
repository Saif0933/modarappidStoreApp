import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashInitProvider = FutureProvider<bool>((ref) async {
  // Simulate initialization delay
  await Future.delayed(const Duration(seconds: 3));
  return true;
});
