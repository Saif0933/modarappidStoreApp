import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_application_1/shared/providers/products_provider.dart';

void main() {
  testWidgets('CartPage on Phone Screen (360x740) matches UI without overflow', (WidgetTester tester) async {
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

    // Header & 30-Min Banner
    expect(find.text('My Cart (3)'), findsOneWidget);
    expect(find.text('30-Minute Delivery'), findsOneWidget);
    expect(find.text('Get your fashion delivered in 30 minutes'), findsOneWidget);

    // Items
    expect(find.text('JCOSTA'), findsOneWidget);
    expect(find.text('Men Solid Casual Black Shirt'), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);

    expect(find.text("Levi's"), findsOneWidget);
    expect(find.text('Men Slim Fit Jeans'), findsOneWidget);
    expect(find.text('₹1,499'), findsOneWidget);

    expect(find.text('Roadster'), findsOneWidget);
    expect(find.text('Men Regular Fit T-Shirt'), findsOneWidget);
    expect(find.text('₹499'), findsOneWidget);

    // Coupons
    expect(find.text('Coupons & Offers'), findsOneWidget);

    // Price Details
    expect(find.text('Price Details'), findsOneWidget);
    expect(find.text('Total MRP (3 items)'), findsOneWidget);
    expect(find.text('₹4,097'), findsOneWidget);
    expect(find.text('Item Discount'), findsOneWidget);
    expect(find.text('- ₹1,400'), findsOneWidget);
    expect(find.text('Total Amount'), findsOneWidget);
    expect(find.text('₹2,727'), findsWidgets);
    expect(find.text('You are saving ₹1,400 on this order!'), findsOneWidget);

    // Checkout Button
    expect(find.text('Proceed to Checkout'), findsOneWidget);

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

    expect(find.text('My Cart (3)'), findsOneWidget);
    expect(find.text('30-Minute Delivery'), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Total Payable'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsOneWidget);
  });
}
