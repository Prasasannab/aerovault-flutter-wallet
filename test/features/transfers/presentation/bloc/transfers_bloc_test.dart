import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/transfers/domain/entities/fx_rate.dart';
import 'package:aerovault/features/transfers/domain/entities/scheduled_transfer.dart';
import 'package:aerovault/features/transfers/domain/entities/wire_routing_info.dart';
import 'package:aerovault/features/transfers/domain/usecases/get_fx_rates_use_case.dart';
import 'package:aerovault/features/transfers/domain/usecases/get_scheduled_transfers_use_case.dart';
import 'package:aerovault/features/transfers/domain/usecases/toggle_scheduled_transfer_use_case.dart';
import 'package:aerovault/features/transfers/domain/usecases/get_wire_routing_use_case.dart';
import 'package:aerovault/features/transfers/presentation/bloc/transfers_bloc.dart';
import 'package:aerovault/features/transfers/presentation/bloc/transfers_event.dart';
import 'package:aerovault/features/transfers/presentation/bloc/transfers_state.dart';

class MockGetFxRatesUseCase extends Mock implements GetFxRatesUseCase {}
class MockGetScheduledTransfersUseCase extends Mock implements GetScheduledTransfersUseCase {}
class MockToggleScheduledTransferUseCase extends Mock implements ToggleScheduledTransferUseCase {}
class MockGetWireRoutingUseCase extends Mock implements GetWireRoutingUseCase {}

void main() {
  late TransfersBloc transfersBloc;
  late MockGetFxRatesUseCase mockGetFxRates;
  late MockGetScheduledTransfersUseCase mockGetScheduledTransfers;
  late MockToggleScheduledTransferUseCase mockToggleScheduledTransfer;
  late MockGetWireRoutingUseCase mockGetWireRouting;

  const testFxRate = FxRate(
    pair: 'EUR / USD',
    baseCurrency: 'EUR',
    quoteCurrency: 'USD',
    rate: 1.0845,
    change24h: 0.42,
    isPositive: true,
  );

  const testScheduledTransfer = ScheduledTransfer(
    id: 'st-001',
    title: 'AWS Enterprise Cloud Stack',
    recipient: 'Amazon Web Services',
    amount: 2450.00,
    currency: 'USD',
    frequency: 'Monthly (1st)',
    nextExecutionDate: 'Dec 01, 2026',
    category: 'Cloud Infrastructure',
    isActive: true,
  );

  const testWireRouting = WireRoutingInfo(
    institutionName: 'AeroVault AG Private Banking',
    swissIban: 'CH93 0076 2011 6238 5295 7',
    swiftBic: 'AEROCHZZ80A',
    clearingCode: 'BC 08765',
    fedwireRouting: '026009593',
    accountHolder: 'Pasindu G.',
    address: 'Bahnhofstrasse 45, 8001 Zurich',
  );

  setUp(() {
    mockGetFxRates = MockGetFxRatesUseCase();
    mockGetScheduledTransfers = MockGetScheduledTransfersUseCase();
    mockToggleScheduledTransfer = MockToggleScheduledTransferUseCase();
    mockGetWireRouting = MockGetWireRoutingUseCase();

    transfersBloc = TransfersBloc(
      getFxRatesUseCase: mockGetFxRates,
      getScheduledTransfersUseCase: mockGetScheduledTransfers,
      toggleScheduledTransferUseCase: mockToggleScheduledTransfer,
      getWireRoutingUseCase: mockGetWireRouting,
    );
  });

  tearDown(() {
    transfersBloc.close();
  });

  test('initial state is TransfersInitial', () {
    expect(transfersBloc.state, equals(const TransfersInitial()));
  });

  blocTest<TransfersBloc, TransfersState>(
    'emits [TransfersLoading, TransfersLoaded] when LoadTransfersHubEvent succeeds',
    build: () {
      when(() => mockGetFxRates()).thenAnswer(
        (_) async => Result.success([testFxRate]),
      );
      when(() => mockGetScheduledTransfers()).thenAnswer(
        (_) async => Result.success([testScheduledTransfer]),
      );
      when(() => mockGetWireRouting()).thenAnswer(
        (_) async => Result.success(testWireRouting),
      );
      return transfersBloc;
    },
    act: (bloc) => bloc.add(const LoadTransfersHubEvent()),
    expect: () => [
      const TransfersLoading(),
      isA<TransfersLoaded>()
          .having((s) => s.fxRates.length, 'fxRates.length', 1)
          .having((s) => s.scheduledTransfers.length, 'scheduledTransfers.length', 1)
          .having((s) => s.wireRouting.swiftBic, 'swiftBic', 'AEROCHZZ80A'),
    ],
  );

  blocTest<TransfersBloc, TransfersState>(
    'toggles standing order status correctly',
    build: () {
      when(() => mockGetFxRates()).thenAnswer(
        (_) async => Result.success([testFxRate]),
      );
      when(() => mockGetScheduledTransfers()).thenAnswer(
        (_) async => Result.success([testScheduledTransfer]),
      );
      when(() => mockGetWireRouting()).thenAnswer(
        (_) async => Result.success(testWireRouting),
      );
      when(() => mockToggleScheduledTransfer(
            transferId: any(named: 'transferId'),
            isActive: any(named: 'isActive'),
          )).thenAnswer(
        (_) async => Result.success(testScheduledTransfer.copyWith(isActive: false)),
      );
      return transfersBloc;
    },
    seed: () => const TransfersLoaded(
      fxRates: [testFxRate],
      scheduledTransfers: [testScheduledTransfer],
      wireRouting: testWireRouting,
    ),
    act: (bloc) => bloc.add(const ToggleStandingOrderEvent(
      transferId: 'st-001',
      isActive: false,
    )),
    expect: () => [
      isA<TransfersLoaded>().having(
        (s) => s.scheduledTransfers.first.isActive,
        'scheduledTransfers.first.isActive',
        false,
      ),
    ],
  );

  blocTest<TransfersBloc, TransfersState>(
    'calculates currency conversion when ConvertCurrencyEvent is dispatched',
    build: () => transfersBloc,
    seed: () => const TransfersLoaded(
      fxRates: [testFxRate],
      scheduledTransfers: [testScheduledTransfer],
      wireRouting: testWireRouting,
    ),
    act: (bloc) => bloc.add(const ConvertCurrencyEvent(
      amount: 2000.0,
      fromCurrency: 'USD',
      toCurrency: 'EUR',
    )),
    expect: () => [
      isA<TransfersLoaded>()
          .having((s) => s.inputAmount, 'inputAmount', 2000.0)
          .having((s) => s.toCurrency, 'toCurrency', 'EUR')
          .having((s) => (s.convertedAmount - (2000.0 / 1.0845)).abs() < 0.01, 'convertedAmount', true),
    ],
  );
}
