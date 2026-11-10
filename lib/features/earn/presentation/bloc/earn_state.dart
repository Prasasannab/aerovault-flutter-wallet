import 'package:equatable/equatable.dart';
import '../../domain/entities/staking_vault.dart';
import '../../domain/entities/yield_summary.dart';

abstract class EarnState extends Equatable {
  const EarnState();

  @override
  List<Object?> get props => [];
}

class EarnInitial extends EarnState {
  const EarnInitial();
}

class EarnLoading extends EarnState {
  const EarnLoading();
}

class EarnLoaded extends EarnState {
  final List<StakingVault> vaults;
  final YieldSummary summary;
  final String? toastMessage;

  const EarnLoaded({
    required this.vaults,
    required this.summary,
    this.toastMessage,
  });

  EarnLoaded copyWith({
    List<StakingVault>? vaults,
    YieldSummary? summary,
    String? toastMessage,
  }) {
    return EarnLoaded(
      vaults: vaults ?? this.vaults,
      summary: summary ?? this.summary,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [vaults, summary, toastMessage];
}

class EarnError extends EarnState {
  final String message;

  const EarnError(this.message);

  @override
  List<Object?> get props => [message];
}
