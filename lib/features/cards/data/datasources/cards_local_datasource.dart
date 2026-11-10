import 'dart:async';
import 'dart:math';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/payment_card.dart';
import '../models/payment_card_model.dart';

abstract class CardsDataSource {
  Future<List<PaymentCardModel>> getCards();
  Future<PaymentCardModel> toggleCardFreeze({required String cardId, required bool freeze});
  Future<PaymentCardModel> updateSpendingLimit({required String cardId, required double limit});
  Future<PaymentCardModel> toggleChannel({
    required String cardId,
    required CardChannel channel,
    required bool isEnabled,
  });
  Future<PaymentCardModel> revealCardDetails({required String cardId});
  Future<PaymentCardModel> regenerateDisposableCard({required String cardId});
  Future<PaymentCardModel> issueNewCard({
    required String name,
    required CardType type,
    required double limit,
  });
}

class CardsLocalDataSourceImpl implements CardsDataSource {
  final List<PaymentCardModel> _cards = [
    const PaymentCardModel(
      id: 'CARD-OBSIDIAN-METAL',
      name: 'AeroVault Obsidian Metal',
      type: CardType.metalPhysical,
      brand: CardBrand.visa,
      cardTier: 'VISA Infinite',
      maskedNumber: '•••• •••• •••• 8842',
      fullNumber: '4532 8842 1092 8842',
      cardholderName: AppConstants.defaultHolderName,
      expiry: '12/29',
      maskedCvv: '•••',
      cvv: '842',
      isFrozen: false,
      spendingLimit: 50000.0,
      currentSpend: 8420.50,
      allowOnline: true,
      allowInternational: true,
      allowContactless: true,
      isSensitiveRevealed: false,
    ),
    const PaymentCardModel(
      id: 'CARD-NEO-VIRTUAL',
      name: 'AeroVault Neo Virtual Debit',
      type: CardType.virtualDebit,
      brand: CardBrand.visa,
      cardTier: 'VISA Signature',
      maskedNumber: '•••• •••• •••• 4190',
      fullNumber: '4111 6720 3840 4190',
      cardholderName: AppConstants.defaultHolderName,
      expiry: '09/27',
      maskedCvv: '•••',
      cvv: '319',
      isFrozen: false,
      spendingLimit: 15000.0,
      currentSpend: 2140.00,
      allowOnline: true,
      allowInternational: false,
      allowContactless: true,
      isSensitiveRevealed: false,
    ),
    const PaymentCardModel(
      id: 'CARD-EPHEMERAL-GHOST',
      name: 'AeroVault Ephemeral Ghost',
      type: CardType.disposableGhost,
      brand: CardBrand.mastercard,
      cardTier: 'Mastercard Cyber-Shield',
      maskedNumber: '•••• •••• •••• 7712',
      fullNumber: '5412 8920 4410 7712',
      cardholderName: AppConstants.defaultHolderName,
      expiry: '04/26',
      maskedCvv: '•••',
      cvv: '584',
      isFrozen: false,
      spendingLimit: 2500.0,
      currentSpend: 180.00,
      allowOnline: true,
      allowInternational: true,
      allowContactless: false,
      isSensitiveRevealed: false,
    ),
  ];

  @override
  Future<List<PaymentCardModel>> getCards() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_cards);
  }

  @override
  Future<PaymentCardModel> toggleCardFreeze({
    required String cardId,
    required bool freeze,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) throw Exception('Card not found');

    final updated = PaymentCardModel.fromEntity(
      _cards[index].copyWith(isFrozen: freeze),
    );
    _cards[index] = updated;
    return updated;
  }

  @override
  Future<PaymentCardModel> updateSpendingLimit({
    required String cardId,
    required double limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) throw Exception('Card not found');

    final updated = PaymentCardModel.fromEntity(
      _cards[index].copyWith(spendingLimit: limit),
    );
    _cards[index] = updated;
    return updated;
  }

  @override
  Future<PaymentCardModel> toggleChannel({
    required String cardId,
    required CardChannel channel,
    required bool isEnabled,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) throw Exception('Card not found');

    final current = _cards[index];
    PaymentCard updatedEntity;
    switch (channel) {
      case CardChannel.online:
        updatedEntity = current.copyWith(allowOnline: isEnabled);
        break;
      case CardChannel.international:
        updatedEntity = current.copyWith(allowInternational: isEnabled);
        break;
      case CardChannel.contactless:
        updatedEntity = current.copyWith(allowContactless: isEnabled);
        break;
    }

    final updated = PaymentCardModel.fromEntity(updatedEntity);
    _cards[index] = updated;
    return updated;
  }

  @override
  Future<PaymentCardModel> revealCardDetails({required String cardId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) throw Exception('Card not found');

    final updated = PaymentCardModel.fromEntity(
      _cards[index].copyWith(
        isSensitiveRevealed: !_cards[index].isSensitiveRevealed,
      ),
    );
    _cards[index] = updated;
    return updated;
  }

  @override
  Future<PaymentCardModel> regenerateDisposableCard({required String cardId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) throw Exception('Card not found');

    final rng = Random();
    final newLast4 = (1000 + rng.nextInt(9000)).toString();
    final newCvv = (100 + rng.nextInt(900)).toString();

    final updated = PaymentCardModel.fromEntity(
      _cards[index].copyWith(
        maskedNumber: '•••• •••• •••• $newLast4',
        fullNumber: '5412 8920 4410 $newLast4',
        cvv: newCvv,
        currentSpend: 0.0,
      ),
    );
    _cards[index] = updated;
    return updated;
  }

  @override
  Future<PaymentCardModel> issueNewCard({
    required String name,
    required CardType type,
    required double limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final rng = Random();
    final newLast4 = (1000 + rng.nextInt(9000)).toString();
    final newCvv = (100 + rng.nextInt(900)).toString();
    final id = 'CARD-CUSTOM-${rng.nextInt(99999)}';

    final brand = type == CardType.disposableGhost ? CardBrand.mastercard : CardBrand.visa;
    final prefix = brand == CardBrand.visa ? '4111 5200 9182' : '5412 3340 7192';

    final newCard = PaymentCardModel(
      id: id,
      name: name,
      type: type,
      brand: brand,
      cardTier: type == CardType.metalPhysical
          ? 'VISA Infinite'
          : (type == CardType.virtualDebit ? 'VISA Platinum' : 'Mastercard Dynamic'),
      maskedNumber: '•••• •••• •••• $newLast4',
      fullNumber: '$prefix $newLast4',
      cardholderName: AppConstants.defaultHolderName,
      expiry: '10/29',
      maskedCvv: '•••',
      cvv: newCvv,
      isFrozen: false,
      spendingLimit: limit,
      currentSpend: 0.0,
      allowOnline: true,
      allowInternational: true,
      allowContactless: type != CardType.disposableGhost,
      isSensitiveRevealed: false,
    );

    _cards.add(newCard);
    return newCard;
  }
}
