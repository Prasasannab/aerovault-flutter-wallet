import 'package:equatable/equatable.dart';
import '../../domain/entities/virtual_card.dart';
import '../../domain/entities/wallet_account.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final WalletAccount account;
  final VirtualCard card;

  const WalletLoaded({
    required this.account,
    required this.card,
  });

  WalletLoaded copyWith({
    WalletAccount? account,
    VirtualCard? card,
  }) {
    return WalletLoaded(
      account: account ?? this.account,
      card: card ?? this.card,
    );
  }

  @override
  List<Object?> get props => [account, card];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
