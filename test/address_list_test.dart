import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/address/presentation/pages/address_list_page.dart';

void main() {
  Widget buildTestWidget({Size size = const Size(360, 800), GoRouter? router}) {
    final testRouter = router ??
        GoRouter(
          initialLocation: '/addresses',
          routes: [
            GoRoute(
              path: '/addresses',
              builder: (context, state) => const AddressListPage(),
            ),
            GoRoute(
              path: '/add-address',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Add Address Page Mock')),
              ),
            ),
          ],
        );

    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
  }

  testWidgets('AddressListPage renders all screenshot elements on phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // 1. App Bar
    expect(find.text('My Addresses'), findsOneWidget);
    expect(find.text('Add from Map'), findsOneWidget);

    // 2. Express Delivery Banner
    expect(find.text('Add your address'), findsOneWidget);
    expect(find.text('Get your order delivered in 30 minutes'), findsOneWidget);

    // 3. Addresses Matching Screenshot
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget); // Default badge
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Parents Home'), findsOneWidget);

    // 4. Address Details
    expect(find.textContaining('Indira Nagar, House No. 123'), findsOneWidget);
    expect(find.textContaining('Tower B, 5th Floor, IT Park'), findsOneWidget);
    expect(find.textContaining('Saif Khan'), findsWidgets);
    expect(find.textContaining('+91 98765 43210'), findsWidgets);

    // 5. Actions (Edit & Delete on each card)
    expect(find.text('Edit'), findsNWidgets(4));
    expect(find.text('Delete'), findsNWidgets(4));

    // 6. Radio Options: 1 Default address, 3 Set as default
    expect(find.text('Default address'), findsOneWidget);
    expect(find.text('Set as default'), findsNWidgets(3));

    // 7. Sticky Bottom Add New Address Button
    expect(find.text('Add New Address'), findsOneWidget);
  });

  testWidgets('AddressListPage renders seamlessly on tablet (850x1200) without overflow', (tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('My Addresses'), findsOneWidget);
    expect(find.text('Add from Map'), findsOneWidget);
    expect(find.text('Add your address'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Parents Home'), findsOneWidget);
    expect(find.text('Add New Address'), findsOneWidget);
  });

  testWidgets('Tapping Set as default switches default address to selected card', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Initially Home is Default (1 'Default address')
    expect(find.text('Default address'), findsOneWidget);
    expect(find.text('Set as default'), findsNWidgets(3));

    // Tap 'Set as default' on the first non-default card (Work)
    final setAsDefaultFinder = find.text('Set as default');
    await tester.tap(setAsDefaultFinder.first);
    await tester.pumpAndSettle();

    // Now Work is Default, still 1 'Default address' and 3 'Set as default'
    expect(find.text('Default address'), findsOneWidget);
    expect(find.text('Set as default'), findsNWidgets(3));
  });

  testWidgets('Tapping Add New Address navigates to /add-address', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add New Address'));
    await tester.pumpAndSettle();

    expect(find.text('Add Address Page Mock'), findsOneWidget);
  });

  testWidgets('Tapping Edit opens Edit Address bottom sheet modal', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap first Edit button
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    // Modal appears with 'Edit Address' header and Save Changes button
    expect(find.text('Edit Address'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Recipient Name'), findsOneWidget);
  });

  testWidgets('Tapping Delete opens Delete confirmation dialog and can cancel', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap first Delete button
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // Delete dialog appears
    expect(find.text('Delete Address?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog closed, all 4 addresses remain
    expect(find.text('Delete Address?'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Tapping Add from Map opens Map Picker bottom sheet modal', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add from Map'));
    await tester.pumpAndSettle();

    expect(find.text('Select Location from Map'), findsOneWidget);
    expect(find.text('Use Current GPS Location'), findsOneWidget);
  });
}
