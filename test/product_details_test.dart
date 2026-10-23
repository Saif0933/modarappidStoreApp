import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/product/presentation/pages/product_details_page.dart';

void main() {
  final testProduct = {
    'id': 'p1',
    'title': 'Women Floral Dress',
    'price': '₹1,299',
    'originalPrice': '₹1,899',
    'discount': '32% OFF',
    'image': 'assets/images/prod_detail_main.png',
  };

  testWidgets('ProductDetailsPage on Phone Screen (360x800) matches UI without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductDetailsPage(productData: testProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title, Best Seller, and Rating
    expect(find.text('Women Floral Dress'), findsOneWidget);
    expect(find.text('Best Seller'), findsOneWidget);
    expect(find.text('₹1,299'), findsOneWidget);
    expect(find.text('32% OFF'), findsOneWidget);

    // Verify Color and Size selectors
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Pink'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('Size Chart'), findsOneWidget);

    // Test Size selection
    expect(find.text('L'), findsOneWidget);
    await tester.tap(find.text('L'));
    await tester.pumpAndSettle();

    // Test Quantity increment/decrement
    expect(find.text('1'), findsWidgets);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    // Verify Features
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Delivery to Home'), findsOneWidget);
    expect(find.text('ModaRapp Fashion'), findsOneWidget);

    // Verify Sticky Bottom Bar Buttons
    expect(find.text('Buy Now'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('ProductDetailsPage on Tablet Screen (850x1200) dual-pane layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductDetailsPage(productData: testProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Sections render cleanly
    expect(find.text('Women Floral Dress'), findsOneWidget);
    expect(find.text('Best Seller'), findsOneWidget);
    expect(find.text('Product Description'), findsOneWidget);
    expect(find.text('Delivery to Home'), findsOneWidget);
    expect(find.text('Buy Now'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('ProductDetailsPage in Light Theme on Phone Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductDetailsPage(productData: testProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Women Floral Dress'), findsOneWidget);
    expect(find.text('Buy Now'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });
}
