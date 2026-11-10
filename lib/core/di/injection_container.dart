import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import '../../features/analytics/data/datasources/analytics_mock_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_portfolio_performance_usecase.dart';
import '../../features/analytics/domain/usecases/get_wealth_analytics_usecase.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/auth/domain/usecases/authenticate_biometric_usecase.dart';
import '../../features/auth/domain/usecases/verify_pin_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cards/data/datasources/cards_local_datasource.dart';
import '../../features/cards/data/repositories/cards_repository_impl.dart';
import '../../features/cards/domain/repositories/cards_repository.dart';
import '../../features/cards/domain/usecases/get_cards_usecase.dart';
import '../../features/cards/domain/usecases/issue_new_card_usecase.dart';
import '../../features/cards/domain/usecases/regenerate_disposable_card_usecase.dart';
import '../../features/cards/domain/usecases/reveal_card_details_usecase.dart';
import '../../features/cards/domain/usecases/toggle_card_channel_usecase.dart';
import '../../features/cards/domain/usecases/toggle_card_freeze_usecase.dart';
import '../../features/cards/domain/usecases/update_card_limit_usecase.dart';
import '../../features/cards/presentation/bloc/cards_bloc.dart';
import '../../features/transactions/data/datasources/transaction_mock_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/get_transactions_usecase.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../features/wallet/data/datasources/wallet_local_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_virtual_card_usecase.dart';
import '../../features/wallet/domain/usecases/get_wallet_account_usecase.dart';
import '../../features/wallet/domain/usecases/toggle_balance_visibility_usecase.dart';
import '../../features/wallet/domain/usecases/toggle_card_freeze_usecase.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/transfers/data/datasources/transfers_data_source.dart';
import '../../features/transfers/data/repositories/transfers_repository_impl.dart';
import '../../features/transfers/domain/repositories/transfers_repository.dart';
import '../../features/transfers/domain/usecases/get_fx_rates_use_case.dart';
import '../../features/transfers/domain/usecases/get_scheduled_transfers_use_case.dart';
import '../../features/transfers/domain/usecases/get_wire_routing_use_case.dart';
import '../../features/transfers/domain/usecases/toggle_scheduled_transfer_use_case.dart';
import '../../features/transfers/presentation/bloc/transfers_bloc.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../network/ssl_pinning_client.dart';
import '../security/anti_tamper_service.dart';
import '../security/biometric_service.dart';
import '../security/hardware_keystore_service.dart';
import '../security/security_service.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

/// Initialize all core dependencies and service singletons
Future<void> initCoreDependencies() async {
  // 1. External & Platform
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
      aOptions: AndroidOptions(
        resetOnError: true,
      ),
    ),
  );

  sl.registerLazySingleton<LocalAuthentication>(
    () => LocalAuthentication(),
  );

  // 2. Core Security Services
  sl.registerLazySingleton<HardwareKeystoreService>(
    () => HardwareKeystoreService(storage: sl()),
  );

  sl.registerLazySingleton<BiometricService>(
    () => BiometricService(localAuth: sl()),
  );

  sl.registerLazySingleton<AntiTamperService>(
    () => AntiTamperService(),
  );

  sl.registerLazySingleton<SecurityService>(
    () => SecurityService(
      keystoreService: sl(),
      biometricService: sl(),
      antiTamperService: sl(),
    ),
  );

  // 3. Core Network & SSL Pinning
  sl.registerLazySingleton<Dio>(() {
    final dio = SslPinningClient.createSecureDio(enforcePinning: false); // Set true in strict prod
    dio.interceptors.add(
      AuthInterceptor(
        keystoreService: sl(),
        dio: dio,
      ),
    );
    return dio;
  });

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl()),
  );

  // 4. Feature: Wallet
  sl.registerLazySingleton<WalletDataSource>(
    () => WalletDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetWalletAccountUseCase>(
    () => GetWalletAccountUseCase(sl()),
  );
  sl.registerLazySingleton<GetVirtualCardUseCase>(
    () => GetVirtualCardUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleCardFreezeUseCase>(
    () => ToggleCardFreezeUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleBalanceVisibilityUseCase>(
    () => ToggleBalanceVisibilityUseCase(sl()),
  );
  sl.registerFactory<WalletBloc>(
    () => WalletBloc(
      getWalletAccountUseCase: sl(),
      getVirtualCardUseCase: sl(),
      toggleCardFreezeUseCase: sl(),
      toggleBalanceVisibilityUseCase: sl(),
    ),
  );

  // 5. Feature: Transactions
  sl.registerLazySingleton<TransactionDataSource>(
    () => TransactionDataSourceImpl(),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetTransactionsUseCase>(
    () => GetTransactionsUseCase(sl()),
  );
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(getTransactionsUseCase: sl()),
  );

  // 6. Feature: Analytics
  sl.registerLazySingleton<AnalyticsDataSource>(
    () => AnalyticsDataSourceImpl(),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetPortfolioPerformanceUseCase>(
    () => GetPortfolioPerformanceUseCase(sl()),
  );
  sl.registerLazySingleton<GetWealthAnalyticsUseCase>(
    () => GetWealthAnalyticsUseCase(sl()),
  );
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(
      getPortfolioPerformanceUseCase: sl(),
      getWealthAnalyticsUseCase: sl(),
    ),
  );

  // 7. Theme Management
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(),
  );

  // 8. Feature: Auth & Scrambled PIN
  sl.registerLazySingleton<VerifyPinUseCase>(
    () => VerifyPinUseCase(sl()),
  );
  sl.registerLazySingleton<AuthenticateBiometricUseCase>(
    () => AuthenticateBiometricUseCase(sl()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      verifyPinUseCase: sl(),
      authenticateBiometricUseCase: sl(),
      securityService: sl(),
    ),
  );

  // 9. Feature: Cards Management Studio
  sl.registerLazySingleton<CardsDataSource>(
    () => CardsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CardsRepository>(
    () => CardsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetCardsUseCase>(
    () => GetCardsUseCase(sl()),
  );
  sl.registerLazySingleton<TogglePaymentCardFreezeUseCase>(
    () => TogglePaymentCardFreezeUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateCardLimitUseCase>(
    () => UpdateCardLimitUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleCardChannelUseCase>(
    () => ToggleCardChannelUseCase(sl()),
  );
  sl.registerLazySingleton<RevealCardDetailsUseCase>(
    () => RevealCardDetailsUseCase(sl()),
  );
  sl.registerLazySingleton<RegenerateDisposableCardUseCase>(
    () => RegenerateDisposableCardUseCase(sl()),
  );
  sl.registerLazySingleton<IssueNewCardUseCase>(
    () => IssueNewCardUseCase(sl()),
  );
  sl.registerFactory<CardsBloc>(
    () => CardsBloc(
      getCardsUseCase: sl(),
      toggleCardFreezeUseCase: sl(),
      updateCardLimitUseCase: sl(),
      toggleCardChannelUseCase: sl(),
      revealCardDetailsUseCase: sl(),
      regenerateDisposableCardUseCase: sl(),
      issueNewCardUseCase: sl(),
    ),
  );

  // 10. Feature: Transfers Hub & Global FX Exchange
  sl.registerLazySingleton<TransfersDataSource>(
    () => TransfersLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<TransfersRepository>(
    () => TransfersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetFxRatesUseCase>(
    () => GetFxRatesUseCase(sl()),
  );
  sl.registerLazySingleton<GetScheduledTransfersUseCase>(
    () => GetScheduledTransfersUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleScheduledTransferUseCase>(
    () => ToggleScheduledTransferUseCase(sl()),
  );
  sl.registerLazySingleton<GetWireRoutingUseCase>(
    () => GetWireRoutingUseCase(sl()),
  );
  sl.registerFactory<TransfersBloc>(
    () => TransfersBloc(
      getFxRatesUseCase: sl(),
      getScheduledTransfersUseCase: sl(),
      toggleScheduledTransferUseCase: sl(),
      getWireRoutingUseCase: sl(),
    ),
  );
}
