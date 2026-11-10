import 'package:equatable/equatable.dart';

enum CardType {
  metalPhysical,
  virtualDebit,
  disposableGhost,
}

enum CardBrand {
  visa,
  mastercard,
}

enum CardChannel {
  online,
  international,
  contactless,
}

/// Domain Entity representing a bank-issued high-tier payment card
class PaymentCard extends Equatable {
  final String id;
  final String name;
  final CardType type;
  final CardBrand brand;
  final String cardTier;
  final String maskedNumber;
  final String fullNumber;
  final String cardholderName;
  final String expiry;
  final String maskedCvv;
  final String cvv;
  final bool isFrozen;
  final double spendingLimit;
  final double currentSpend;
  final bool allowOnline;
  final bool allowInternational;
  final bool allowContactless;
  final bool isSensitiveRevealed;

  const PaymentCard({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.cardTier,
    required this.maskedNumber,
    required this.fullNumber,
    required this.cardholderName,
    required this.expiry,
    required this.maskedCvv,
    required this.cvv,
    this.isFrozen = false,
    this.spendingLimit = 25000.0,
    this.currentSpend = 4200.0,
    this.allowOnline = true,
    this.allowInternational = true,
    this.allowContactless = true,
    this.isSensitiveRevealed = false,
  });

  double get remainingLimit => (spendingLimit - currentSpend).clamp(0.0, spendingLimit);
  double get spendPercentage => spendingLimit > 0 ? (currentSpend / spendingLimit).clamp(0.0, 1.0) : 0.0;

  String get displayCardNumber => isSensitiveRevealed ? fullNumber : maskedNumber;
  String get displayCvv => isSensitiveRevealed ? cvv : maskedCvv;

  PaymentCard copyWith({
    String? id,
    String? name,
    CardType? type,
    CardBrand? brand,
    String? cardTier,
    String? maskedNumber,
    String? fullNumber,
    String? cardholderName,
    String? expiry,
    String? maskedCvv,
    String? cvv,
    bool? isFrozen,
    double? spendingLimit,
    double? currentSpend,
    bool? allowOnline,
    bool? allowInternational,
    bool? allowContactless,
    bool? isSensitiveRevealed,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      cardTier: cardTier ?? this.cardTier,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      fullNumber: fullNumber ?? this.fullNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiry: expiry ?? this.expiry,
      maskedCvv: maskedCvv ?? this.maskedCvv,
      cvv: cvv ?? this.cvv,
      isFrozen: isFrozen ?? this.isFrozen,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      currentSpend: currentSpend ?? this.currentSpend,
      allowOnline: allowOnline ?? this.allowOnline,
      allowInternational: allowInternational ?? this.allowInternational,
      allowContactless: allowContactless ?? this.allowContactless,
      isSensitiveRevealed: isSensitiveRevealed ?? this.isSensitiveRevealed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        brand,
        cardTier,
        maskedNumber,
        fullNumber,
        cardholderName,
        expiry,
        maskedCvv,
        cvv,
        isFrozen,
        spendingLimit,
        currentSpend,
        allowOnline,
        allowInternational,
        allowContactless,
        isSensitiveRevealed,
      ];
}
