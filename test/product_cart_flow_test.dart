import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_application_1/features/category/presentation/pages/product_categories_page.dart';
import 'package:flutter_application_1/features/product/presentation/pages/product_details_page.dart';
import 'package:flutter_application_1/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter_application_1/shared/providers/products_provider.dart';

void main() {
  testWidgets('Add to Cart from ProductDetailsPage adds item and updates cart state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    container.read(cartProvider.notifier).clearCart();
    expect(container.read(cartProvider).isEmpty, isTrue);

    final testProduct = {
      'id': 'test_p1',
      'title': 'Oversized Floral T-Shirt',
      'brand': 'Roadster',
      'price': '₹699',
      'originalPrice': '₹999',
      'discount': '30% OFF',
      'image': 'assets/images/cat_prod_1.png',
    };

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

    // Verify Title & Price rendered
    expect(find.text('Oversized Floral T-Shirt'), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);

    // Click "Add to Cart"
    final addToCartBtn = find.text('Add to Cart');
    expect(addToCartBtn, findsOneWidget);
    await tester.tap(addToCartBtn);
    await tester.pumpAndSettle();

    // Verify item was added to cartProvider
    final cartItems = container.read(cartProvider);
    expect(cartItems.length, 1);
    expect(cartItems.first.product.title, 'Oversized Floral T-Shirt');
    expect(cartItems.first.product.price, 699.0);

    // Now render CartPage with the same container
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

    // Verify Cart Page displays the item without error
    expect(find.text('My Cart (1)'), findsOneWidget);
    expect(find.text('Oversized Floral T-Shirt'), findsOneWidget);
    expect(find.text('₹699'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsOneWidget);
  });

  testWidgets('Add to Cart from ProductCategoriesPage adds product to Cart', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    container.read(cartProvider.notifier).clearCart();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProductCategoriesPage(categoryName: "Men's Fashion"),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap first "Add to Cart" button in grid
    final addButtons = find.text('Add to Cart');
    expect(addButtons, findsWidgets);
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Verify item was added to cartProvider
    expect(container.read(cartProvider).length, 1);
  });

  testWidgets('Move to Cart from WishlistPage adds product to Cart', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    container.read(cartProvider.notifier).clearCart();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const WishlistPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap "Move to Cart" button
    final moveButtons = find.text('Move to Cart');
    expect(moveButtons, findsWidgets);
    await tester.tap(moveButtons.first);
    await tester.pumpAndSettle();

    // Verify item was added to cartProvider
    expect(container.read(cartProvider).length, 1);
  });
}
