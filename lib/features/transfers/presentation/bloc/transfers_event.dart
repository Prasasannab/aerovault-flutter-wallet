import 'package:equatable/equatable.dart';

abstract class TransfersEvent extends Equatable {
  const TransfersEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransfersHubEvent extends TransfersEvent {
  const LoadTransfersHubEvent();
}

class ToggleStandingOrderEvent extends TransfersEvent {
  final String transferId;
  final bool isActive;

  const ToggleStandingOrderEvent({
    required this.transferId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [transferId, isActive];
}

class ConvertCurrencyEvent extends TransfersEvent {
  final double amount;
  final String fromCurrency;
  final String toCurrency;

  const ConvertCurrencyEvent({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [amount, fromCurrency, toCurrency];
}
