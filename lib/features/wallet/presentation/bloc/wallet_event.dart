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
