import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/address/presentation/pages/address_list_page.dart';
import 'package:flutter_application_1/features/profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('Tapping My Addresses in ProfilePage opens AddressListPage without Page Not Found', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testRouter = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) => const AddressListPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Profile page is loaded
    expect(find.text('My Account'), findsOneWidget);
    expect(find.text('My Addresses'), findsOneWidget);

    // Scroll until My Addresses is visible and tap
    await tester.scrollUntilVisible(find.text('My Addresses'), 150);
    await tester.tap(find.text('My Addresses'));
    await tester.pumpAndSettle();

    // Verify AddressListPage is displayed
    expect(find.text('Add New Address'), findsOneWidget);
    expect(find.textContaining('Page not found'), findsNothing);
    expect(find.textContaining('404'), findsNothing);
  });

  testWidgets('Tapping Addresses stat in ProfilePage opens AddressListPage', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testRouter = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) => const AddressListPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find "Addresses" stat
    expect(find.text('Addresses'), findsOneWidget);
    await tester.tap(find.text('Addresses'));
    await tester.pumpAndSettle();

    // Verify AddressListPage is displayed
    expect(find.text('Add New Address'), findsOneWidget);
    expect(find.textContaining('Page not found'), findsNothing);
  });
}
