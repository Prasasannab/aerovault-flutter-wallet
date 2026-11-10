import 'package:equatable/equatable.dart';

abstract class EarnEvent extends Equatable {
  const EarnEvent();

  @override
  List<Object?> get props => [];
}

class LoadEarnVaultsEvent extends EarnEvent {
  const LoadEarnVaultsEvent();
}

class StakeAssetEvent extends EarnEvent {
  final String vaultId;
  final double amount;

  const StakeAssetEvent({
    required this.vaultId,
    required this.amount,
  });

  @override
  List<Object?> get props => [vaultId, amount];
}

class UnstakeAssetEvent extends EarnEvent {
  final String vaultId;
  final double amount;

  const UnstakeAssetEvent({
    required this.vaultId,
    required this.amount,
  });

  @override
  List<Object?> get props => [vaultId, amount];
}

class ClaimAllYieldEvent extends EarnEvent {
  const ClaimAllYieldEvent();
}
