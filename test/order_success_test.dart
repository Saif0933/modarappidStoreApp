import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/cart/presentation/pages/order_success_page.dart';

void main() {
  testWidgets('OrderSuccessPage on Phone Screen (360x740) renders attractive UI without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderSuccessPage(orderId: 'ORD-98231'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Top Badges & Hero
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('Order Confirmed'), findsOneWidget);
    expect(find.text('30-Minute Express Delivery'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);

    // 2. Timeline nodes
    expect(find.text('Placed'), findsOneWidget);
    expect(find.text('Packing'), findsOneWidget);
    expect(find.text('On the way'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);

    // 3. Order Reference
    expect(find.text('Order Reference'), findsOneWidget);
    expect(find.text('ORD-98231'), findsOneWidget);
    expect(find.text('UPI Paid'), findsOneWidget);

    // 4. Items & Address
    expect(find.text('You saved ₹1,000 on this order!'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // 5. Mystery Scratch Card & Action Buttons
    expect(find.text('You Unlocked a Mystery Scratch Card!'), findsOneWidget);
    expect(find.text('Track Order Live'), findsOneWidget);
    expect(find.text('Continue Shopping'), findsOneWidget);

    // 6. Test Scratch Card Interaction
    await tester.ensureVisible(find.text('SCRATCH'));
    await tester.tap(find.text('SCRATCH'));
    await tester.pumpAndSettle();

    expect(find.text('Woohoo! You Won!'), findsOneWidget);
    expect(find.text('CASHBACK100'), findsOneWidget);

    await tester.tap(find.text('Awesome, Thanks!'));
    await tester.pumpAndSettle();

    expect(find.text('₹100 Cashback Unlocked!'), findsOneWidget);
  });

  testWidgets('OrderSuccessPage on Tablet Screen (850x1200) renders centered responsive layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderSuccessPage(orderId: 'ORD-98231'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('30-Minute Express Delivery'), findsOneWidget);
    expect(find.text('Track Order Live'), findsOneWidget);
    expect(find.text('Continue Shopping'), findsOneWidget);
  });
}
