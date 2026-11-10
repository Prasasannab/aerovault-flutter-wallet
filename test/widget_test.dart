import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerovault/core/constants/app_constants.dart';
import 'package:aerovault/core/di/injection_container.dart';
import 'package:aerovault/core/theme/aerovault_colors.dart';
import 'package:aerovault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aerovault/features/analytics/presentation/screens/growth_screen.dart';
import 'package:aerovault/features/auth/presentation/screens/scrambled_pin_screen.dart';
import 'package:aerovault/features/auth/presentation/screens/security_lockout_screen.dart';
import 'package:aerovault/features/cards/presentation/screens/cards_screen.dart';
import 'package:aerovault/features/transfers/presentation/screens/transfers_screen.dart';
import 'package:aerovault/features/notifications/presentation/widgets/notifications_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/receive_funds_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/send_money_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/swap_crypto_sheet.dart';
import 'package:aerovault/features/transfers/presentation/widgets/top_up_sheet.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:aerovault/features/wallet/presentation/widgets/multi_currency_sheet.dart';
import 'package:aerovault/features/wallet/presentation/widgets/multi_currency_selector_bar.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:aerovault/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
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



  testWidgets('SecurityAuditScreen renders all bank-grade security indicators and navigation controls', (WidgetTester tester) async {
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

    // Verify back and close navigation controls
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('RETURN TO MAIN DASHBOARD'), findsOneWidget);
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

  testWidgets('CardsScreen renders multi-card studio, carousel, and channel security switches', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AeroVaultColors.dark()]),
        home: const CardsScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Cards Studio'), findsOneWidget);
    expect(find.text('NEW CARD'), findsOneWidget);
    expect(find.text('CARD SECRETS'), findsOneWidget);
    expect(find.text('MONTHLY SPENDING BUDGET'), findsOneWidget);
    expect(find.text('SECURITY & CHANNEL PERMISSIONS'), findsOneWidget);
    expect(find.text('Freeze & Lock Card'), findsOneWidget);
    expect(find.text('Online & In-App Purchases'), findsOneWidget);
  });

  testWidgets('GrowthScreen renders net worth, allocation profile, and statement action', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AeroVaultColors.dark()]),
        home: const GrowthScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Wealth Growth'), findsOneWidget);
    expect(find.text('PDF STMT'), findsOneWidget);
    expect(find.text('TOTAL CONSOLIDATED NET WORTH'), findsOneWidget);
    expect(find.text('ASSET ALLOCATION PROFILE'), findsOneWidget);
    expect(find.text('EXPENDITURE BREAKDOWN'), findsOneWidget);
  });

  testWidgets('TransfersScreen renders FX hub, action launchpad, and standing orders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AeroVaultColors.dark()]),
        home: const TransfersScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Transfers & FX Hub'), findsOneWidget);
    expect(find.text('TRANSFER ACTIONS'), findsOneWidget);
    expect(find.text('LIVE INSTITUTIONAL FX RATES'), findsOneWidget);
    expect(find.text('Instant Interbank Converter'), findsOneWidget);
    expect(find.text('STANDING ORDERS & RECURRING TRANSFERS'), findsOneWidget);
    expect(find.text('Swiss Wire Routing Specs'), findsOneWidget);
  });

  testWidgets('NotificationsSheet renders audit alerts, filter chips, and encrypted footer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AeroVaultColors.dark()]),
        home: const Scaffold(
          body: NotificationsSheet(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Audit & Alerts'), findsOneWidget);
    expect(find.text('FINMA AUDIT & TELEMETRY STREAM'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Transfers'), findsOneWidget);
    expect(find.text('Compliance'), findsOneWidget);
    expect(find.text('Upwork Global Escrow Wire Credited'), findsOneWidget);
    expect(find.text('Mark All Read'), findsOneWidget);
  });

  testWidgets('MultiCurrencySheet renders multi-currency sub-accounts and IBANs', (WidgetTester tester) async {
    final bloc = sl<WalletBloc>();
    await tester.pumpWidget(
      BlocProvider<WalletBloc>.value(
        value: bloc..add(const LoadWalletEvent()),
        child: MaterialApp(
          theme: ThemeData(extensions: [AeroVaultColors.dark()]),
          home: const Scaffold(
            body: MultiCurrencySheet(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Multi-Currency Studio'), findsOneWidget);
    expect(find.text('GLOBAL DEDICATED IBANS & HOLDINGS'), findsOneWidget);
    expect(find.text('Exchange'), findsOneWidget);
    expect(find.text('US Dollar'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
    expect(find.text('Swiss Franc'), findsOneWidget);
  });

  testWidgets('MultiCurrencySelectorBar renders currency pills and drawer toggle', (WidgetTester tester) async {
    final bloc = sl<WalletBloc>();
    await tester.pumpWidget(
      BlocProvider<WalletBloc>.value(
        value: bloc..add(const LoadWalletEvent()),
        child: MaterialApp(
          theme: ThemeData(extensions: [AeroVaultColors.dark()]),
          home: Scaffold(
            body: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is! WalletLoaded) return const SizedBox.shrink();
                return MultiCurrencySelectorBar(account: state.account);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('USD'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('CHF'), findsOneWidget);
  });
}


