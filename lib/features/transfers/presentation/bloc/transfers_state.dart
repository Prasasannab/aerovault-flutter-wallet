import 'package:equatable/equatable.dart';
import '../../domain/entities/fx_rate.dart';
import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/entities/wire_routing_info.dart';

abstract class TransfersState extends Equatable {
  const TransfersState();

  @override
  List<Object?> get props => [];
}

class TransfersInitial extends TransfersState {
  const TransfersInitial();
}

class TransfersLoading extends TransfersState {
  const TransfersLoading();
}

class TransfersLoaded extends TransfersState {
  final List<FxRate> fxRates;
  final List<ScheduledTransfer> scheduledTransfers;
  final WireRoutingInfo wireRouting;
  final double inputAmount;
  final String fromCurrency;
  final String toCurrency;
  final double convertedAmount;

  const TransfersLoaded({
    required this.fxRates,
    required this.scheduledTransfers,
    required this.wireRouting,
    this.inputAmount = 1000.0,
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.convertedAmount = 922.08,
  });

  TransfersLoaded copyWith({
    List<FxRate>? fxRates,
    List<ScheduledTransfer>? scheduledTransfers,
    WireRoutingInfo? wireRouting,
    double? inputAmount,
    String? fromCurrency,
    String? toCurrency,
    double? convertedAmount,
  }) {
    return TransfersLoaded(
      fxRates: fxRates ?? this.fxRates,
      scheduledTransfers: scheduledTransfers ?? this.scheduledTransfers,
      wireRouting: wireRouting ?? this.wireRouting,
      inputAmount: inputAmount ?? this.inputAmount,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }

  @override
  List<Object?> get props => [
        fxRates,
        scheduledTransfers,
        wireRouting,
        inputAmount,
        fromCurrency,
        toCurrency,
        convertedAmount,
      ];
}

class TransfersError extends TransfersState {
  final String message;

  const TransfersError(this.message);

  @override
  List<Object?> get props => [message];
}
