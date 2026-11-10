import '../models/fx_rate_model.dart';
import '../models/scheduled_transfer_model.dart';
import '../models/wire_routing_model.dart';

abstract class TransfersDataSource {
  Future<List<FxRateModel>> getFxRates();
  Future<List<ScheduledTransferModel>> getScheduledTransfers();
  Future<ScheduledTransferModel> toggleScheduledTransfer({
    required String transferId,
    required bool isActive,
  });
  Future<WireRoutingModel> getWireRoutingInfo();
}

class TransfersLocalDataSourceImpl implements TransfersDataSource {
  final List<ScheduledTransferModel> _scheduledTransfers = [
    const ScheduledTransferModel(
      id: 'st-001',
      title: 'AWS Enterprise Cloud Stack',
      recipient: 'Amazon Web Services EMEA SARL',
      amount: 2450.00,
      currency: 'USD',
      frequency: 'Monthly (1st)',
      nextExecutionDate: 'Dec 01, 2026',
      category: 'Cloud Infrastructure',
      isActive: true,
    ),
    const ScheduledTransferModel(
      id: 'st-002',
      title: 'Zurich Wealth Family Office Retainer',
      recipient: 'Künzli & Partner Vermögensverwaltung',
      amount: 5000.00,
      currency: 'CHF',
      frequency: 'Monthly (15th)',
      nextExecutionDate: 'Nov 15, 2026',
      category: 'Private Wealth Advisory',
      isActive: true,
    ),
    const ScheduledTransferModel(
      id: 'st-003',
      title: 'Bitcoin Treasury Cold DCA',
      recipient: 'AeroVault Institutional Cold Reserve',
      amount: 1000.00,
      currency: 'USD',
      frequency: 'Weekly (Every Monday)',
      nextExecutionDate: 'Nov 16, 2026',
      category: 'Asset Allocation',
      isActive: true,
    ),
    const ScheduledTransferModel(
      id: 'st-004',
      title: 'Bloomberg Professional Terminal',
      recipient: 'Bloomberg Finance L.P.',
      amount: 2200.00,
      currency: 'USD',
      frequency: 'Monthly (28th)',
      nextExecutionDate: 'Nov 28, 2026',
      category: 'Financial Intelligence',
      isActive: false,
    ),
  ];

  static const List<FxRateModel> _fxRates = [
    FxRateModel(
      pair: 'EUR / USD',
      baseCurrency: 'EUR',
      quoteCurrency: 'USD',
      rate: 1.0845,
      change24h: 0.42,
      isPositive: true,
      sparklineTrend: 'up',
    ),
    FxRateModel(
      pair: 'GBP / USD',
      baseCurrency: 'GBP',
      quoteCurrency: 'USD',
      rate: 1.2930,
      change24h: 0.18,
      isPositive: true,
      sparklineTrend: 'up',
    ),
    FxRateModel(
      pair: 'USD / CHF',
      baseCurrency: 'USD',
      quoteCurrency: 'CHF',
      rate: 0.8840,
      change24h: -0.15,
      isPositive: false,
      sparklineTrend: 'down',
    ),
    FxRateModel(
      pair: 'BTC / USD',
      baseCurrency: 'BTC',
      quoteCurrency: 'USD',
      rate: 94820.00,
      change24h: 3.45,
      isPositive: true,
      sparklineTrend: 'up',
    ),
    FxRateModel(
      pair: 'ETH / USD',
      baseCurrency: 'ETH',
      quoteCurrency: 'USD',
      rate: 3460.50,
      change24h: 1.85,
      isPositive: true,
      sparklineTrend: 'up',
    ),
    FxRateModel(
      pair: 'SOL / USD',
      baseCurrency: 'SOL',
      quoteCurrency: 'USD',
      rate: 218.40,
      change24h: 5.12,
      isPositive: true,
      sparklineTrend: 'up',
    ),
  ];

  static const WireRoutingModel _wireRouting = WireRoutingModel(
    institutionName: 'AeroVault AG Private Banking',
    swissIban: 'CH93 0076 2011 6238 5295 7',
    swiftBic: 'AEROCHZZ80A',
    clearingCode: 'BC 08765 (SIX Interbank)',
    fedwireRouting: '026009593',
    accountHolder: 'Pasindu G. (VIP Tier 1)',
    address: 'Bahnhofstrasse 45, 8001 Zurich, Switzerland',
  );

  @override
  Future<List<FxRateModel>> getFxRates() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_fxRates);
  }

  @override
  Future<List<ScheduledTransferModel>> getScheduledTransfers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_scheduledTransfers);
  }

  @override
  Future<ScheduledTransferModel> toggleScheduledTransfer({
    required String transferId,
    required bool isActive,
  }) async {
    final index = _scheduledTransfers.indexWhere((t) => t.id == transferId);
    if (index == -1) {
      throw Exception('Scheduled transfer not found: $transferId');
    }
    final updated = _scheduledTransfers[index].copyWith(isActive: isActive);
    _scheduledTransfers[index] = ScheduledTransferModel(
      id: updated.id,
      title: updated.title,
      recipient: updated.recipient,
      amount: updated.amount,
      currency: updated.currency,
      frequency: updated.frequency,
      nextExecutionDate: updated.nextExecutionDate,
      category: updated.category,
      isActive: updated.isActive,
    );
    return _scheduledTransfers[index];
  }

  @override
  Future<WireRoutingModel> getWireRoutingInfo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _wireRouting;
  }
}
