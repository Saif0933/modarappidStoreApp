import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/orders/presentation/pages/order_details_page.dart';

void main() {
  testWidgets('OrderDetailsPage on Phone Screen (360x800) renders all 6 statuses without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderDetailsPage(
            orderId: 'OD438063137903616100',
            initialStatus: OrderDetailStatus.delivered,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Common Header & Product Summary
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('JCOSTA Men Solid Casual Black Shirt'), findsOneWidget);
    expect(find.text('Size: M  •  Color: Black'), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);
    expect(find.text('Qty: 1'), findsOneWidget);
    expect(find.text('Order #OD438063137903616100'), findsOneWidget);

    // 2. Verify Delivered Status Banner & Details
    expect(find.text('Delivered, Jul 17'), findsOneWidget);
    expect(find.text('Your order has been delivered successfully.'), findsOneWidget);
    expect(find.text('Delivery Details'), findsOneWidget);
    expect(find.text('Delivered on'), findsOneWidget);
    expect(find.text('Wed, 17 Jul, 2024 at 04:20 PM'), findsOneWidget);
    expect(find.text('Delivered to'), findsOneWidget);
    expect(find.text('Rohit Kumar'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Indira Nagar, Lucknow, Uttar Pradesh'), findsOneWidget);
    expect(find.text('View tracking details'), findsOneWidget);
    expect(find.text('Rate your experience'), findsOneWidget);
    expect(find.text('Rate the product'), findsOneWidget);
    expect(find.text('Buy Again'), findsOneWidget);
    expect(find.text('Return / Exchange'), findsOneWidget);

    // 3. Test Ola Maps interactive preview expansion
    await tester.tap(find.text('View tracking details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Ola Maps Platform'), findsOneWidget);
    expect(find.text('Delivered via ModaRapp Express on Ola Maps'), findsOneWidget);
    expect(find.text('Live Track'), findsOneWidget);

    // 4. Test Switching to Cancelled
    await tester.ensureVisible(find.text('Cancelled'));
    await tester.tap(find.text('Cancelled'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cancelled, Jul 16'), findsOneWidget);
    expect(find.text('Your order has been cancelled.'), findsOneWidget);
    expect(find.text('Cancellation Details'), findsOneWidget);
    expect(find.text('Cancelled on'), findsOneWidget);
    expect(find.text('Tue, 16 Jul, 2024 at 11:30 AM'), findsOneWidget);
    expect(find.text('Reason'), findsOneWidget);
    expect(find.text('Cancelled by you'), findsOneWidget);
    expect(find.text('Payment Details'), findsOneWidget);
    expect(find.text('Need help with this order?'), findsOneWidget);

    // 5. Test Switching to Refunded (Amber)
    await tester.ensureVisible(find.text('Refunded (Amber)'));
    await tester.tap(find.text('Refunded (Amber)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Refunded, Jul 20'), findsOneWidget);
    expect(find.text('Your refund has been processed.'), findsOneWidget);
    expect(find.text('Refund Details'), findsOneWidget);
    expect(find.text('Sat, 20 Jul, 2024 at 02:15 PM'), findsOneWidget);
    expect(find.text('T2024072014152635'), findsOneWidget);
    expect(find.text('Amount has been credited to your bank account. It may take 2-3 business days to reflect.'), findsOneWidget);

    // 6. Test Switching to Return Requested
    await tester.ensureVisible(find.text('Return Requested'));
    await tester.tap(find.text('Return Requested'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Return Requested, Jul 19'), findsOneWidget);
    expect(find.text('Return Details'), findsOneWidget);
    expect(find.text('Fri, 19 Jul, 2024 at 10:45 AM'), findsOneWidget);
    expect(find.text('Size issue'), findsOneWidget);
    expect(find.text('View Return Status'), findsOneWidget);
    expect(find.text('Need Help'), findsOneWidget);

    // 7. Test Switching to Returning
    await tester.ensureVisible(find.text('Returning'));
    await tester.tap(find.text('Returning'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Returning, Jul 21'), findsOneWidget);
    expect(find.text('Return Tracking'), findsOneWidget);
    expect(find.text('Pickup completed'), findsOneWidget);
    expect(find.text('At warehouse'), findsOneWidget);
    expect(find.text('Quality check'), findsOneWidget);
    expect(find.text('Refund process'), findsOneWidget);
    expect(find.text('Track Return Courier on Ola Maps'), findsOneWidget);

    // 8. Test Switching to Refunded (Green)
    await tester.ensureVisible(find.text('Refunded (Green)'));
    await tester.tap(find.text('Refunded (Green)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Refunded, Jul 24'), findsOneWidget);
    expect(find.text('Your return has been accepted and refund has been processed.'), findsOneWidget);
    expect(find.text('Wed, 24 Jul, 2024 at 11:20 AM'), findsOneWidget);
    expect(find.text('T2024072411203589'), findsOneWidget);
  });

  testWidgets('OrderDetailsPage on Tablet Screen (850x1200) responsive layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderDetailsPage(
            orderId: 'OD438063137903616100',
            initialStatus: OrderDetailStatus.delivered,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Title & Delivered state on Tablet
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Delivered, Jul 17'), findsOneWidget);
    expect(find.text('Delivery Details'), findsOneWidget);
    expect(find.text('Buy Again'), findsOneWidget);

    // Test Ola Maps preview expansion on Tablet
    await tester.tap(find.text('View tracking details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Ola Maps Platform'), findsOneWidget);
  });
}
