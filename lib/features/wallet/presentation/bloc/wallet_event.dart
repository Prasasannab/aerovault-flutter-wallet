import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletEvent extends WalletEvent {
  const LoadWalletEvent();
}

class ToggleCardFreezeEvent extends WalletEvent {
  final bool freeze;
  const ToggleCardFreezeEvent({required this.freeze});

  @override
  List<Object?> get props => [freeze];
}

class ToggleBalanceVisibilityEvent extends WalletEvent {
  final bool hide;
  const ToggleBalanceVisibilityEvent({required this.hide});

  @override
  List<Object?> get props => [hide];
}

class AdjustWalletBalanceEvent extends WalletEvent {
  final double fiatDelta;
  final double btcDelta;
  final double ethDelta;

  const AdjustWalletBalanceEvent({
    this.fiatDelta = 0.0,
    this.btcDelta = 0.0,
    this.ethDelta = 0.0,
  });

  @override
  List<Object?> get props => [fiatDelta, btcDelta, ethDelta];
}

