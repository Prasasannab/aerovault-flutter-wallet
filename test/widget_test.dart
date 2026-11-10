import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerovault/core/constants/app_constants.dart';
import 'package:aerovault/core/di/injection_container.dart';
import 'package:aerovault/core/theme/aerovault_colors.dart';
import 'package:aerovault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aerovault/features/auth/presentation/screens/scrambled_pin_screen.dart';
import 'package:aerovault/features/auth/presentation/screens/security_lockout_screen.dart';
import 'package:aerovault/features/transfers/presentation/widgets/receive_funds_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/send_money_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/swap_crypto_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/top_up_sheet.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:aerovault/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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

  testWidgets('ReceiveFundsSheet renders wire details and switches to crypto QR', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AeroVaultColors.dark()]),
        home: const Scaffold(body: ReceiveFundsSheet()),
      ),
    );
    await tester.pump();

    expect(find.text('Receive Funds'), findsOneWidget);
    expect(find.text('Fiat Wire (IBAN/SWIFT)'), findsOneWidget);
    expect(find.text('Crypto (QR / Address)'), findsOneWidget);
    expect(find.text('AeroVault Sovereign Trust Ltd'), findsOneWidget);
    expect(find.text('CH93 0076 2011 6238 5295 7'), findsOneWidget);

    // Switch to crypto tab
    await tester.tap(find.text('Crypto (QR / Address)'));
    await tester.pump();
    expect(find.text('Bitcoin Native SegWit'), findsOneWidget);
  });

  testWidgets('SendMoneySheet renders recipient selector and numeric keypad', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletBloc>(create: (_) => sl<WalletBloc>()..add(const LoadWalletEvent())),
          BlocProvider<TransactionBloc>(create: (_) => sl<TransactionBloc>()..add(const LoadTransactionsEvent())),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [AeroVaultColors.dark()]),
          home: const Scaffold(body: SendMoneySheet()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Send Money'), findsOneWidget);
    expect(find.text('SELECT RECIPIENT'), findsOneWidget);
    expect(find.text('Elena'), findsOneWidget);
    expect(find.text('ENTER AMOUNT'), findsOneWidget);
    expect(find.text('Authorize \$500.00 Transfer'), findsOneWidget);
  });

  testWidgets('SwapCryptoSheet renders asset cards and flip button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletBloc>(create: (_) => sl<WalletBloc>()..add(const LoadWalletEvent())),
          BlocProvider<TransactionBloc>(create: (_) => sl<TransactionBloc>()..add(const LoadTransactionsEvent())),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [AeroVaultColors.dark()]),
          home: const Scaffold(body: SwapCryptoSheet()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Instant Swap'), findsOneWidget);
    expect(find.text('YOU PAY'), findsOneWidget);
    expect(find.text('YOU RECEIVE (ESTIMATED)'), findsOneWidget);
    expect(find.text('Confirm Instant Swap'), findsOneWidget);
  });

  testWidgets('TopUpSheet renders deposit methods and instant CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletBloc>(create: (_) => sl<WalletBloc>()..add(const LoadWalletEvent())),
          BlocProvider<TransactionBloc>(create: (_) => sl<TransactionBloc>()..add(const LoadTransactionsEvent())),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [AeroVaultColors.dark()]),
          home: const Scaffold(body: TopUpSheet()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Add Funds'), findsOneWidget);
    expect(find.text('DEPOSIT AMOUNT'), findsOneWidget);
    expect(find.text('CHOOSE PAYMENT METHOD'), findsOneWidget);
    expect(find.text('Apple Pay'), findsOneWidget);
    expect(find.text('Deposit \$1000.00 Instantly'), findsOneWidget);
  });

  testWidgets('ScrambledPinScreen renders security emblem, scrambled digits, and attempt count', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>(
        create: (_) => sl<AuthBloc>(),
        child: MaterialApp(
          theme: ThemeData(extensions: [AeroVaultColors.dark()]),
          home: const ScrambledPinScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Security Authentication'), findsOneWidget);
    expect(find.text('Anti-Spy Scramble Active • Tap to Reshuffle'), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
  });

  testWidgets('SecurityLockoutScreen renders suspended warning, audit box, and recovery action', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AeroVaultColors.dark()]),
        home: const SecurityLockoutScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Vault Access Suspended'), findsOneWidget);
    expect(find.text('Security Lockout Activated'), findsOneWidget);
    expect(find.text('Hardware Keystore'), findsOneWidget);
    expect(find.text('PURGED & CLEARED'), findsOneWidget);
    expect(find.text('Restore Access (Reset Demo Lockout)'), findsOneWidget);
  });
}


