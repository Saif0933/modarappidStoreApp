import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/profile/presentation/pages/edit_profile_page.dart';

void main() {
  testWidgets('EditProfilePage renders UI matching screenshot on Phone Screen (360x800)', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EditProfilePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Edit Profile'), findsOneWidget);

    // Verify Avatar name and verified badges
    expect(find.text('Mohammad Saif'), findsAtLeastNWidgets(1));
    expect(find.text('+91 98765 43210'), findsAtLeastNWidgets(2)); // Avatar row & address card
    expect(find.text('Verified'), findsAtLeastNWidgets(2)); // Avatar row & phone field

    // Verify Form Labels
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);

    // Verify Gender options
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Verify DOB
    expect(find.text('15 Mar 1998'), findsOneWidget);

    // Verify Default Address Card
    expect(find.text('Default Address'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Indira Nagar, House No. 123,'), findsOneWidget);
    expect(find.text('Lucknow, Uttar Pradesh - 226016'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);

    // Verify Additional Information
    expect(find.text('Additional Information'), findsOneWidget);
    expect(find.text('Occupation'), findsOneWidget);
    expect(find.text('Software Engineer'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('Lucknow'), findsOneWidget);

    // Verify Save Changes button
    expect(find.text('Save Changes'), findsOneWidget);

    // Verify Gender selection interaction
    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();

    // Verify Save Changes button tap
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
  });

  testWidgets('EditProfilePage renders cleanly on Tablet Screen (850x1200) without overflow', (tester) async {
    tester.view.physicalSize = const Size(850, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EditProfilePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Mohammad Saif'), findsAtLeastNWidgets(1));
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
