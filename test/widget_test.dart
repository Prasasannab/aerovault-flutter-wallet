import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerovault/core/constants/app_constants.dart';
import 'package:aerovault/core/di/injection_container.dart';
import 'package:aerovault/main.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await initCoreDependencies();
  });

  testWidgets('AeroVaultApp dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AeroVaultApp());
    // Initial frame
    await tester.pump();
    // Allow simulated 350ms network delay to resolve and states to load
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify User Greeting & Security Badge
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Pasindu G.'), findsWidgets);
    expect(find.text('SECURE'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Receive'), findsOneWidget);
    expect(find.text('Swap'), findsOneWidget);
    expect(find.text('Top-up'), findsOneWidget);

    // Verify Portfolio Growth & Transactions
    expect(find.text('Portfolio Growth'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('SecurityAuditScreen renders all bank-grade security indicators', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SecurityAuditScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('ENTERPRISE SECURITY CORE'), findsOneWidget);
    expect(find.text('Hardware Keystore / Secure Enclave'), findsOneWidget);
    expect(find.text('SSL Certificate & Public Key Pinning'), findsOneWidget);
    expect(find.text('Anti-Tamper & Root Detection'), findsOneWidget);
  });
}
