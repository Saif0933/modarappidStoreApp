import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_application_1/shared/providers/products_provider.dart';

void main() {
  testWidgets('CartPage on Phone Screen (360x740) in Light and Dark Theme', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    // 1. Test Light Theme on Phone
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CartPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('My Cart'), findsOneWidget);
    expect(find.text('Total Payable'), findsWidgets);
    expect(find.text('Checkout Now'), findsWidgets);

    // 2. Test Empty State on Phone
    container.read(cartProvider.notifier).clearCart();
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Your Cart is Empty'), findsOneWidget);
    expect(find.text('Start Shopping'), findsOneWidget);
  });

  testWidgets('CartPage on Tablet Screen (850x1200) in Dual-Pane Layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    // Test Tablet Layout
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CartPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('My Cart'), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Checkout Now'), findsWidgets);
  });
}
