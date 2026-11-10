import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_fx_rates_use_case.dart';
import '../../domain/usecases/get_scheduled_transfers_use_case.dart';
import '../../domain/usecases/toggle_scheduled_transfer_use_case.dart';
import '../../domain/usecases/get_wire_routing_use_case.dart';
import 'transfers_event.dart';
import 'transfers_state.dart';

class TransfersBloc extends Bloc<TransfersEvent, TransfersState> {
  final GetFxRatesUseCase getFxRatesUseCase;
  final GetScheduledTransfersUseCase getScheduledTransfersUseCase;
  final ToggleScheduledTransferUseCase toggleScheduledTransferUseCase;
  final GetWireRoutingUseCase getWireRoutingUseCase;

  TransfersBloc({
    required this.getFxRatesUseCase,
    required this.getScheduledTransfersUseCase,
    required this.toggleScheduledTransferUseCase,
    required this.getWireRoutingUseCase,
  }) : super(const TransfersInitial()) {
    on<LoadTransfersHubEvent>(_onLoadTransfersHub);
    on<ToggleStandingOrderEvent>(_onToggleStandingOrder);
    on<ConvertCurrencyEvent>(_onConvertCurrency);
  }

  Future<void> _onLoadTransfersHub(
    LoadTransfersHubEvent event,
    Emitter<TransfersState> emit,
  ) async {
    emit(const TransfersLoading());

    final ratesResult = await getFxRatesUseCase();
    final transfersResult = await getScheduledTransfersUseCase();
    final routingResult = await getWireRoutingUseCase();

    final rates = ratesResult.dataOrNull;
    final transfers = transfersResult.dataOrNull;
    final routing = routingResult.dataOrNull;

    if (rates != null && transfers != null && routing != null) {
      final converted = _calculateConversion(
        amount: 1000.0,
        from: 'USD',
        to: 'EUR',
      );

      emit(TransfersLoaded(
        fxRates: rates,
        scheduledTransfers: transfers,
        wireRouting: routing,
        inputAmount: 1000.0,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        convertedAmount: converted,
      ));
    } else {
      emit(const TransfersError('Failed to load transfers hub telemetry'));
    }
  }

  Future<void> _onToggleStandingOrder(
    ToggleStandingOrderEvent event,
    Emitter<TransfersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransfersLoaded) return;

    final result = await toggleScheduledTransferUseCase(
      transferId: event.transferId,
      isActive: event.isActive,
    );

    if (result.isSuccess) {
      final updatedList = currentState.scheduledTransfers.map((item) {
        if (item.id == event.transferId) {
          return item.copyWith(isActive: event.isActive);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(scheduledTransfers: updatedList));
    }
  }

  void _onConvertCurrency(
    ConvertCurrencyEvent event,
    Emitter<TransfersState> emit,
  ) {
    final currentState = state;
    if (currentState is! TransfersLoaded) return;

    final converted = _calculateConversion(
      amount: event.amount,
      from: event.fromCurrency,
      to: event.toCurrency,
    );

    emit(currentState.copyWith(
      inputAmount: event.amount,
      fromCurrency: event.fromCurrency,
      toCurrency: event.toCurrency,
      convertedAmount: converted,
    ));
  }

  double _calculateConversion({
    required double amount,
    required String from,
    required String to,
  }) {
    if (from == to) return amount;

    // Direct USD base conversion logic for institutional liquidity
    if (from == 'USD' && to == 'EUR') return amount / 1.0845;
    if (from == 'EUR' && to == 'USD') return amount * 1.0845;
    if (from == 'USD' && to == 'GBP') return amount / 1.2930;
    if (from == 'GBP' && to == 'USD') return amount * 1.2930;
    if (from == 'USD' && to == 'CHF') return amount * 0.8840;
    if (from == 'CHF' && to == 'USD') return amount / 0.8840;
    if (from == 'USD' && to == 'BTC') return amount / 94820.00;
    if (from == 'BTC' && to == 'USD') return amount * 94820.00;
    if (from == 'USD' && to == 'ETH') return amount / 3460.50;
    if (from == 'ETH' && to == 'USD') return amount * 3460.50;

    return amount;
  }
}
