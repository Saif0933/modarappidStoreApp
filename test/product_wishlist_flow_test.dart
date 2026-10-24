import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/features/category/presentation/pages/product_categories_page.dart';
import 'package:flutter_application_1/features/product/presentation/pages/product_details_page.dart';
import 'package:flutter_application_1/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter_application_1/shared/providers/products_provider.dart';

void main() {
  testWidgets('Add to Wishlist from ProductCategoriesPage adds product to wishlistProvider', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    container.read(wishlistProvider.notifier).clearWishlist();
    expect(container.read(wishlistProvider).length, 0);

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

    // Find heart icon on first product card
    final heartIcons = find.byIcon(Icons.favorite_border_rounded);
    expect(heartIcons, findsWidgets);

    // Tap the first product heart icon (second heart in tree, first is top bar)
    await tester.tap(heartIcons.at(1));
    await tester.pumpAndSettle();

    // Verify item was added to wishlistProvider
    expect(container.read(wishlistProvider).length, 1);
  });

  testWidgets('Add to Wishlist from ProductDetailsPage adds product to wishlistProvider', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    container.read(wishlistProvider.notifier).clearWishlist();
    expect(container.read(wishlistProvider).length, 0);

    final productData = {
      'id': 'test_p1',
      'title': 'Test Jacket',
      'brand': 'UrbanStyle',
      'price': '₹2,499',
      'originalPrice': '₹3,499',
      'rating': '4.8',
      'reviews': '(500)',
      'image': 'assets/images/prod_detail_main.png',
      'imageUrl': 'assets/images/prod_detail_main.png',
      'category': 'Jackets',
    };

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductDetailsPage(productData: productData),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap top bar heart icon
    final heartIcons = find.byIcon(Icons.favorite_border_rounded);
    expect(heartIcons, findsWidgets);
    await tester.tap(heartIcons.first);
    await tester.pumpAndSettle();

    // Verify item was added to wishlistProvider
    expect(container.read(wishlistProvider).length, 1);
    expect(container.read(wishlistProvider).first.title, 'Test Jacket');
  });

  testWidgets('WishlistPage displays added items and allows removing them', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    container.read(wishlistProvider.notifier).clearWishlist();

    const sample = Product(
      id: 'sample_1',
      title: 'Sample Sneakers',
      brand: 'Sporty',
      imageUrl: 'assets/images/wishlist_img_4.png',
      price: 1499.0,
      originalPrice: 1999.0,
      rating: 4.6,
      reviewsCount: 300,
      weight: '8',
      description: 'Comfortable sneakers',
      category: 'Footwear',
    );
    container.read(wishlistProvider.notifier).addToWishlist(sample);
    expect(container.read(wishlistProvider).length, 1);

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

    // Verify title displayed
    expect(find.text('Sample Sneakers'), findsOneWidget);

    // Tap 3 dots menu
    final menuButton = find.byIcon(Icons.more_vert_rounded);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Tap Remove from Wishlist
    final removeOption = find.text('Remove from Wishlist');
    expect(removeOption, findsOneWidget);
    await tester.tap(removeOption);
    await tester.pumpAndSettle();

    // Verify removed from provider
    expect(container.read(wishlistProvider).length, 0);
    expect(find.text('Your Wishlist is Empty'), findsOneWidget);
  });
}
