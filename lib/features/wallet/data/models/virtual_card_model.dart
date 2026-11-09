import '../../domain/entities/virtual_card.dart';

/// Data Model for Virtual Card with JSON serialization
class VirtualCardModel extends VirtualCard {
  const VirtualCardModel({
    required super.id,
    required super.cardNumberMasked,
    required super.cardholderName,
    required super.expiry,
    required super.cvvMasked,
    super.cardTier = 'VISA Platinum',
    super.isFrozen = false,
    super.spendingLimit = 25000.00,
    super.currentSpend = 4320.50,
  });

  factory VirtualCardModel.fromJson(Map<String, dynamic> json) {
    return VirtualCardModel(
      id: json['id'] as String,
      cardNumberMasked: json['card_number_masked'] as String,
      cardholderName: json['cardholder_name'] as String,
      expiry: json['expiry'] as String,
      cvvMasked: json['cvv_masked'] as String,
      cardTier: json['card_tier'] as String? ?? 'VISA Platinum',
      isFrozen: json['is_frozen'] as bool? ?? false,
      spendingLimit: (json['spending_limit'] as num?)?.toDouble() ?? 25000.00,
      currentSpend: (json['current_spend'] as num?)?.toDouble() ?? 4320.50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_number_masked': cardNumberMasked,
      'cardholder_name': cardholderName,
      'expiry': expiry,
      'cvv_masked': cvvMasked,
      'card_tier': cardTier,
      'is_frozen': isFrozen,
      'spending_limit': spendingLimit,
      'current_spend': currentSpend,
    };
  }

  factory VirtualCardModel.fromEntity(VirtualCard entity) {
    return VirtualCardModel(
      id: entity.id,
      cardNumberMasked: entity.cardNumberMasked,
      cardholderName: entity.cardholderName,
      expiry: entity.expiry,
      cvvMasked: entity.cvvMasked,
      cardTier: entity.cardTier,
      isFrozen: entity.isFrozen,
      spendingLimit: entity.spendingLimit,
      currentSpend: entity.currentSpend,
    );
  }
}
