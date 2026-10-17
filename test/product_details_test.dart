import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/product/presentation/pages/product_details_page.dart';

void main() {
  final testProduct = {
    'id': 'p1',
    'title': "Men's Premium Cotton Casual Shirt",
    'brand': 'URBAN CREW',
    'price': 1199.0,
    'originalPrice': 1999.0,
    'discount': '40% OFF',
    'rating': 4.5,
    'reviewsCount': '1.2K',
    'imageUrl': '',
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
          theme: AppTheme.darkTheme,
          home: ProductDetailsPage(productData: testProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand, Title, and discount badge on hero
    expect(find.text('URBAN CREW'), findsOneWidget);
    expect(find.text("Men's Premium Cotton Casual Shirt"), findsWidgets);
    expect(find.text('-40%'), findsOneWidget);

    // Scroll down to Pricing & Coupon
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();

    expect(find.text('₹1,199'), findsOneWidget);
    expect(find.text('₹1,999'), findsOneWidget);
    expect(find.text('40% OFF'), findsOneWidget);
    expect(find.text('Get extra 10% off'), findsOneWidget);
    expect(find.text('Use code FASHION10'), findsOneWidget);

    // Scroll further down to Color, Size, Quantity
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(find.text('Color: Purple'), findsOneWidget);
    expect(find.text('Size: M'), findsOneWidget);

    // Test Size change to 'L'
    await tester.tap(find.text('L'));
    await tester.pumpAndSettle();
    expect(find.text('Size: L'), findsOneWidget);

    // Test Quantity increment
    expect(find.text('1'), findsWidgets);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    // Test Quantity decrement
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsWidgets);

    // Scroll down to Features
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Premium\nCotton'), findsOneWidget);
    expect(find.text('Breathable\nFabric'), findsOneWidget);
    expect(find.text('Skin\nFriendly'), findsOneWidget);
    expect(find.text('Perfect\nFit'), findsOneWidget);

    // Scroll down to Delivery Information
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();

    expect(find.text('Delivery Information'), findsOneWidget);

    // Verify Sticky Bottom Bar Buttons (always visible without scrolling)
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
          theme: AppTheme.darkTheme,
          home: ProductDetailsPage(productData: testProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Sections render cleanly
    expect(find.text("Men's Premium Cotton Casual Shirt"), findsWidgets);
    expect(find.text('URBAN CREW'), findsOneWidget);
    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Delivery Information'), findsOneWidget);
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

    expect(find.text('URBAN CREW'), findsOneWidget);
    expect(find.text("Men's Premium Cotton Casual Shirt"), findsWidgets);
    expect(find.text('Buy Now'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });
}
