import 'package:equatable/equatable.dart';

/// Domain Entity representing a bank-issued Platinum Virtual Debit Card
class VirtualCard extends Equatable {
  final String id;
  final String cardNumberMasked;
  final String cardholderName;
  final String expiry;
  final String cvvMasked;
  final String cardTier;
  final bool isFrozen;
  final double spendingLimit;
  final double currentSpend;

  const VirtualCard({
    required this.id,
    required this.cardNumberMasked,
    required this.cardholderName,
    required this.expiry,
    required this.cvvMasked,
    this.cardTier = 'VISA Platinum',
    this.isFrozen = false,
    this.spendingLimit = 25000.00,
    this.currentSpend = 4320.50,
  });

  double get remainingLimit => (spendingLimit - currentSpend).clamp(0.0, spendingLimit);
  double get spendPercentage => spendingLimit > 0 ? (currentSpend / spendingLimit) : 0.0;

  VirtualCard copyWith({
    String? id,
    String? cardNumberMasked,
    String? cardholderName,
    String? expiry,
    String? cvvMasked,
    String? cardTier,
    bool? isFrozen,
    double? spendingLimit,
    double? currentSpend,
  }) {
    return VirtualCard(
      id: id ?? this.id,
      cardNumberMasked: cardNumberMasked ?? this.cardNumberMasked,
      cardholderName: cardholderName ?? this.cardholderName,
      expiry: expiry ?? this.expiry,
      cvvMasked: cvvMasked ?? this.cvvMasked,
      cardTier: cardTier ?? this.cardTier,
      isFrozen: isFrozen ?? this.isFrozen,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      currentSpend: currentSpend ?? this.currentSpend,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cardNumberMasked,
        cardholderName,
        expiry,
        cvvMasked,
        cardTier,
        isFrozen,
        spendingLimit,
        currentSpend,
      ];
}
