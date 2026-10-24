import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/address/presentation/pages/address_list_page.dart';
import 'package:flutter_application_1/features/home/presentation/pages/home_page.dart';
import 'package:flutter_application_1/shared/providers/products_provider.dart';

void main() {
  testWidgets('HomePage dynamically reflects selected address from AddressListPage', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testRouter = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/address-list',
          builder: (context, state) => const AddressListPage(),
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) => const AddressListPage(),
        ),
      ],
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial State: Home is default
    expect(find.text('Deliver to Home'), findsOneWidget);
    expect(find.textContaining('Indira Nagar'), findsWidgets);

    // 2. Tap Delivery Info to open AddressListPage
    await tester.tap(find.text('Deliver to Home'));
    await tester.pumpAndSettle();

    // Verify AddressListPage is opened
    expect(find.text('My Addresses'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    // 3. Select 'Work' address by tapping its card / radio
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    // Verify Work is now Default address
    expect(find.text('Default address set to Work'), findsOneWidget);

    // 4. Pop / Go Back to HomePage
    testRouter.pop();
    await tester.pumpAndSettle();

    // 5. Verify HomePage now displays 'Deliver to Work' and Tower B address
    expect(find.text('Deliver to Work'), findsOneWidget);
    expect(find.textContaining('Tower B'), findsOneWidget);
    expect(find.text('Deliver to Home'), findsNothing);

    // 6. Tap again and select 'Parents Home'
    await tester.tap(find.text('Deliver to Work'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Parents Home'), 150);
    await tester.tap(find.text('Parents Home'));
    await tester.pumpAndSettle();

    testRouter.pop();
    await tester.pumpAndSettle();

    // 7. Verify HomePage now displays 'Deliver to Parents Home'
    expect(find.text('Deliver to Parents Home'), findsOneWidget);
    expect(find.textContaining('Chinhat'), findsOneWidget);
    expect(find.text('Deliver to Work'), findsNothing);
  });

  testWidgets('HomePage delivery info renders without overflow on narrow screen (360x800)', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Set a very long address
    container.read(addressListProvider.notifier).setDefaultAddress('a2'); // Work

    final testRouter = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Deliver to Work'), findsOneWidget);
    expect(find.text('30 Minutes'), findsOneWidget);
  });
}
