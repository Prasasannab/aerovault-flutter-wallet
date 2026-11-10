import '../../domain/entities/payment_card.dart';

class PaymentCardModel extends PaymentCard {
  const PaymentCardModel({
    required super.id,
    required super.name,
    required super.type,
    required super.brand,
    required super.cardTier,
    required super.maskedNumber,
    required super.fullNumber,
    required super.cardholderName,
    required super.expiry,
    required super.maskedCvv,
    required super.cvv,
    super.isFrozen = false,
    super.spendingLimit = 25000.0,
    super.currentSpend = 4200.0,
    super.allowOnline = true,
    super.allowInternational = true,
    super.allowContactless = true,
    super.isSensitiveRevealed = false,
  });

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    return PaymentCardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CardType.virtualDebit,
      ),
      brand: CardBrand.values.firstWhere(
        (e) => e.name == json['brand'],
        orElse: () => CardBrand.visa,
      ),
      cardTier: json['card_tier'] as String,
      maskedNumber: json['masked_number'] as String,
      fullNumber: json['full_number'] as String,
      cardholderName: json['cardholder_name'] as String,
      expiry: json['expiry'] as String,
      maskedCvv: json['masked_cvv'] as String,
      cvv: json['cvv'] as String,
      isFrozen: json['is_frozen'] as bool? ?? false,
      spendingLimit: (json['spending_limit'] as num?)?.toDouble() ?? 25000.0,
      currentSpend: (json['current_spend'] as num?)?.toDouble() ?? 4200.0,
      allowOnline: json['allow_online'] as bool? ?? true,
      allowInternational: json['allow_international'] as bool? ?? true,
      allowContactless: json['allow_contactless'] as bool? ?? true,
      isSensitiveRevealed: json['is_sensitive_revealed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'brand': brand.name,
      'card_tier': cardTier,
      'masked_number': maskedNumber,
      'full_number': fullNumber,
      'cardholder_name': cardholderName,
      'expiry': expiry,
      'masked_cvv': maskedCvv,
      'cvv': cvv,
      'is_frozen': isFrozen,
      'spending_limit': spendingLimit,
      'current_spend': currentSpend,
      'allow_online': allowOnline,
      'allow_international': allowInternational,
      'allow_contactless': allowContactless,
      'is_sensitive_revealed': isSensitiveRevealed,
    };
  }

  factory PaymentCardModel.fromEntity(PaymentCard entity) {
    return PaymentCardModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      brand: entity.brand,
      cardTier: entity.cardTier,
      maskedNumber: entity.maskedNumber,
      fullNumber: entity.fullNumber,
      cardholderName: entity.cardholderName,
      expiry: entity.expiry,
      maskedCvv: entity.maskedCvv,
      cvv: entity.cvv,
      isFrozen: entity.isFrozen,
      spendingLimit: entity.spendingLimit,
      currentSpend: entity.currentSpend,
      allowOnline: entity.allowOnline,
      allowInternational: entity.allowInternational,
      allowContactless: entity.allowContactless,
      isSensitiveRevealed: entity.isSensitiveRevealed,
    );
  }
}
