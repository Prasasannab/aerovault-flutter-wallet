import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/claim_all_yield_use_case.dart';
import '../../domain/usecases/get_earn_vaults_use_case.dart';
import '../../domain/usecases/stake_asset_use_case.dart';
import '../../domain/usecases/unstake_asset_use_case.dart';
import 'earn_event.dart';
import 'earn_state.dart';

class EarnBloc extends Bloc<EarnEvent, EarnState> {
  final GetEarnVaultsUseCase getEarnVaultsUseCase;
  final StakeAssetUseCase stakeAssetUseCase;
  final UnstakeAssetUseCase unstakeAssetUseCase;
  final ClaimAllYieldUseCase claimAllYieldUseCase;

  EarnBloc({
    required this.getEarnVaultsUseCase,
    required this.stakeAssetUseCase,
    required this.unstakeAssetUseCase,
    required this.claimAllYieldUseCase,
  }) : super(const EarnInitial()) {
    on<LoadEarnVaultsEvent>(_onLoadEarnVaults);
    on<StakeAssetEvent>(_onStakeAsset);
    on<UnstakeAssetEvent>(_onUnstakeAsset);
    on<ClaimAllYieldEvent>(_onClaimAllYield);
  }

  Future<void> _onLoadEarnVaults(
    LoadEarnVaultsEvent event,
    Emitter<EarnState> emit,
  ) async {
    emit(const EarnLoading());
    final result = await getEarnVaultsUseCase();
    result.fold(
      onSuccess: (data) => emit(EarnLoaded(vaults: data.$1, summary: data.$2)),
      onError: (failure) => emit(EarnError(failure.message)),
    );
  }

  Future<void> _onStakeAsset(
    StakeAssetEvent event,
    Emitter<EarnState> emit,
  ) async {
    final currentState = state;
    if (currentState is EarnLoaded) {
      final result = await stakeAssetUseCase(
        vaultId: event.vaultId,
        amount: event.amount,
      );
      result.fold(
        onSuccess: (data) => emit(
          EarnLoaded(
            vaults: data.$1,
            summary: data.$2,
            toastMessage: 'Successfully deposited and staked into vault.',
          ),
        ),
        onError: (failure) => emit(EarnError(failure.message)),
      );
    }
  }

  Future<void> _onUnstakeAsset(
    UnstakeAssetEvent event,
    Emitter<EarnState> emit,
  ) async {
    final currentState = state;
    if (currentState is EarnLoaded) {
      final result = await unstakeAssetUseCase(
        vaultId: event.vaultId,
        amount: event.amount,
      );
      result.fold(
        onSuccess: (data) => emit(
          EarnLoaded(
            vaults: data.$1,
            summary: data.$2,
            toastMessage: 'Successfully unstaked and returned to primary ledger.',
          ),
        ),
        onError: (failure) => emit(EarnError(failure.message)),
      );
    }
  }

  Future<void> _onClaimAllYield(
    ClaimAllYieldEvent event,
    Emitter<EarnState> emit,
  ) async {
    final currentState = state;
    if (currentState is EarnLoaded) {
      final result = await claimAllYieldUseCase();
      result.fold(
        onSuccess: (data) => emit(
          EarnLoaded(
            vaults: data.$1,
            summary: data.$2,
            toastMessage: 'Claimed \$${data.$3.toStringAsFixed(2)} accrued yield to balance.',
          ),
        ),
        onError: (failure) => emit(EarnError(failure.message)),
      );
    }
  }
}
