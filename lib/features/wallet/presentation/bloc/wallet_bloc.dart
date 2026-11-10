import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_virtual_card_usecase.dart';
import '../../domain/usecases/get_wallet_account_usecase.dart';
import '../../domain/usecases/toggle_balance_visibility_usecase.dart';
import '../../domain/usecases/toggle_card_freeze_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletAccountUseCase getWalletAccountUseCase;
  final GetVirtualCardUseCase getVirtualCardUseCase;
  final ToggleCardFreezeUseCase toggleCardFreezeUseCase;
  final ToggleBalanceVisibilityUseCase toggleBalanceVisibilityUseCase;

  WalletBloc({
    required this.getWalletAccountUseCase,
    required this.getVirtualCardUseCase,
    required this.toggleCardFreezeUseCase,
    required this.toggleBalanceVisibilityUseCase,
  }) : super(const WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<ToggleCardFreezeEvent>(_onToggleCardFreeze);
    on<ToggleBalanceVisibilityEvent>(_onToggleBalanceVisibility);
    on<AdjustWalletBalanceEvent>(_onAdjustWalletBalance);
    on<SwitchCurrencyHoldingEvent>(_onSwitchCurrencyHolding);
  }

  void _onAdjustWalletBalance(
    AdjustWalletBalanceEvent event,
    Emitter<WalletState> emit,
  ) {
    final currentState = state;
    if (currentState is WalletLoaded) {
      final updatedFiat = (currentState.account.fiatBalance + event.fiatDelta).clamp(0.0, double.infinity);
      final updatedBtc = (currentState.account.btcBalance + event.btcDelta).clamp(0.0, double.infinity);
      final updatedEth = (currentState.account.ethBalance + event.ethDelta).clamp(0.0, double.infinity);

      emit(
        currentState.copyWith(
          account: currentState.account.copyWith(
            fiatBalance: updatedFiat,
            btcBalance: updatedBtc,
            ethBalance: updatedEth,
          ),
        ),
      );
    }
  }

  Future<void> _onLoadWallet(
    LoadWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final (accountResult, cardResult) = await (
      getWalletAccountUseCase(),
      getVirtualCardUseCase(),
    ).wait;

    if (accountResult.isSuccess && cardResult.isSuccess) {
      emit(
        WalletLoaded(
          account: accountResult.dataOrNull!,
          card: cardResult.dataOrNull!,
        ),
      );
    } else {
      final errorMsg = accountResult.failureOrNull?.message ??
          cardResult.failureOrNull?.message ??
          'Failed to load banking assets.';
      emit(WalletError(errorMsg));
    }
  }

  Future<void> _onToggleCardFreeze(
    ToggleCardFreezeEvent event,
    Emitter<WalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is WalletLoaded) {
      final result = await toggleCardFreezeUseCase(freeze: event.freeze);
      if (result.isSuccess) {
        emit(
          currentState.copyWith(
            card: currentState.card.copyWith(isFrozen: event.freeze),
          ),
        );
      }
    }
  }

  Future<void> _onToggleBalanceVisibility(
    ToggleBalanceVisibilityEvent event,
    Emitter<WalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is WalletLoaded) {
      final result = await toggleBalanceVisibilityUseCase(hide: event.hide);
      if (result.isSuccess) {
        emit(
          currentState.copyWith(
            account: currentState.account.copyWith(isBalanceHidden: event.hide),
          ),
        );
      }
    }
  }

  void _onSwitchCurrencyHolding(
    SwitchCurrencyHoldingEvent event,
    Emitter<WalletState> emit,
  ) {
    final currentState = state;
    if (currentState is WalletLoaded) {
      emit(
        currentState.copyWith(
          account: currentState.account.copyWith(
            selectedCurrencyCode: event.currencyCode,
          ),
        ),
      );
    }
  }
}
