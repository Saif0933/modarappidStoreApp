import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/orders/presentation/pages/order_tracking_page.dart';

void main() {
  testWidgets('OrderTrackingPage on Phone Screen (360x800) matches UI without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderTrackingPage(orderId: 'MRP12345678'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Order ID
    expect(find.text('Order Tracking'), findsOneWidget);
    expect(find.text('Order #MRP12345678'), findsOneWidget);
    expect(find.text('Arriving in'), findsOneWidget);
    expect(find.text('12 Minutes'), findsOneWidget);

    // Verify Stepper Milestones
    expect(find.text('Order Placed'), findsWidgets);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Packed'), findsWidgets);
    expect(find.text('Out for Delivery'), findsWidgets);
    expect(find.text('Delivered'), findsWidgets);

    // Verify Ola Maps Attribution & Partner
    expect(find.text('Ola Maps Platform'), findsOneWidget);
    expect(find.text('Rohit Kumar'), findsOneWidget);
    expect(find.text('Your Delivery Partner'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('(320 deliveries)'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    // Verify Order Items
    expect(find.text('Order Items (2)'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);
    expect(find.text('Men Oversized T-Shirt'), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);
    expect(find.text('Slim Fit Jeans'), findsOneWidget);
    expect(find.text('₹1,499'), findsOneWidget);

    // Verify Tracking Details Timeline
    expect(find.text('Tracking Details'), findsOneWidget);
    expect(find.text('Your order has been placed successfully.'), findsOneWidget);
    expect(find.text('Your order is out for delivery.'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Cancel Order'), findsOneWidget);
    expect(find.text('Return / Exchange'), findsOneWidget);
    expect(find.text('Need Help?'), findsOneWidget);
  });

  testWidgets('OrderTrackingPage on Tablet Screen (850x1200) responsive layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderTrackingPage(orderId: 'MRP12345678'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Sections render cleanly on Tablet
    expect(find.text('Order Tracking'), findsOneWidget);
    expect(find.text('12 Minutes'), findsOneWidget);
    expect(find.text('Ola Maps Platform'), findsOneWidget);
    expect(find.text('Rohit Kumar'), findsOneWidget);
    expect(find.text('Order Items (2)'), findsOneWidget);
    expect(find.text('Cancel Order'), findsOneWidget);
  });
}
