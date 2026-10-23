import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/category/presentation/pages/product_categories_page.dart';

void main() {
  testWidgets('ProductCategoriesPage on Phone Screen (360x800) matches UI without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProductCategoriesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text("Men's Fashion"), findsOneWidget);
    expect(find.text("Discover the latest trends in men's clothing"), findsOneWidget);

    // Verify Subcategories in Left Rail
    expect(find.text('All'), findsOneWidget);
    expect(find.text('T-Shirts'), findsOneWidget);
    expect(find.text('Shirts'), findsOneWidget);

    // Verify Filter Chips & Product Count
    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('342 Products'), findsOneWidget);

    // Verify Products
    expect(find.text('Oversized T-Shirt'), findsOneWidget);
    expect(find.text('Roadster'), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);

    expect(find.text('Casual Shirt'), findsOneWidget);
    expect(find.text('Peter England'), findsOneWidget);
    expect(find.text('₹1,199'), findsWidgets);

    // Test subcategory switch to 'T-Shirts'
    await tester.tap(find.text('T-Shirts'));
    await tester.pumpAndSettle();

    // Test Grid/List view toggle
    await tester.tap(find.byIcon(Icons.view_agenda_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);

    // Switch back to grid
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('ProductCategoriesPage on Tablet Screen (850x1200) responsive layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProductCategoriesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Sections render cleanly on Tablet
    expect(find.text("Men's Fashion"), findsOneWidget);
    expect(find.text('342 Products'), findsOneWidget);
    expect(find.text('Oversized T-Shirt'), findsOneWidget);
    expect(find.text('Casual Shirt'), findsOneWidget);
    expect(find.text('Slim Fit Jeans'), findsOneWidget);
    expect(find.text('Formal Trousers'), findsOneWidget);
  });
}
