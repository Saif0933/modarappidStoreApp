import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/cart/presentation/pages/checkout_page.dart';

void main() {
  testWidgets('CheckoutPage on Phone Screen (360x740) matches UI without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CheckoutPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header & Stepper
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('30-Minute Delivery'), findsWidgets);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    // 2. Delivery Address Card
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Indira Nagar, House No. 123,'), findsOneWidget);
    expect(find.text('Lucknow, Uttar Pradesh - 226016'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);

    // 3. Order Items (2)
    expect(find.text('Order Items (2)'), findsOneWidget);
    expect(find.text('Edit Cart'), findsOneWidget);
    expect(find.text('JCOSTA Men Solid Casual Black Shirt'), findsOneWidget);
    expect(find.text("Levi's Men Slim Fit Jeans"), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);
    expect(find.text('₹1,499'), findsOneWidget);
    expect(find.text('30% OFF'), findsOneWidget);
    expect(find.text('35% OFF'), findsOneWidget);

    // 4. Coupons & Offers
    expect(find.text('Coupons & Offers'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);
    expect(find.text('FLAT200'), findsOneWidget);
    expect(find.text('You saved ₹200 with this coupon'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);

    // 5. Payment Method
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('UPI (Google Pay, PhonePe, Paytm etc.)'), findsOneWidget);
    expect(find.text('Debit / Credit Card'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);

    // 6. Price Details
    expect(find.text('Price Details'), findsOneWidget);
    expect(find.text('Total MRP (2 items)'), findsOneWidget);
    expect(find.text('₹3,298'), findsOneWidget);
    expect(find.text('Item Discount'), findsOneWidget);
    expect(find.text('- ₹800'), findsOneWidget);
    expect(find.text('Coupon Discount (FLAT200)'), findsOneWidget);
    expect(find.text('- ₹200'), findsOneWidget);
    expect(find.text('Delivery Fee'), findsOneWidget);
    expect(find.text('₹30'), findsOneWidget);
    expect(find.text('Total Amount'), findsOneWidget);
    expect(find.text('₹2,328'), findsWidgets);
    expect(find.text('You are saving ₹1,000 on this order!'), findsOneWidget);

    // 7. Sticky Bottom Bar
    expect(find.text('Place Order'), findsOneWidget);

    // 8. Test Coupon Removal Interaction
    await tester.ensureVisible(find.text('Remove'));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    // After removing coupon, FLAT200 is gone, new total is ₹2,528
    expect(find.text('Apply a coupon to save more'), findsOneWidget);
    expect(find.text('₹2,528'), findsWidgets);
  });

  testWidgets('CheckoutPage on Tablet Screen (850x1200) in Dual-Pane Layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CheckoutPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Order Items (2)'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Price Details'), findsOneWidget);
    expect(find.text('Total Payable'), findsOneWidget);
    expect(find.text('100% Genuine Products'), findsOneWidget);
    expect(find.text('Safe & Encrypted Payments'), findsOneWidget);
    expect(find.text('Easy 7 Days Free Returns'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
  });
}
