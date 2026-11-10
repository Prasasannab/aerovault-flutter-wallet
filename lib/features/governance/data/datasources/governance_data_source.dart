import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/governance_request.dart';
import '../models/approval_signer_model.dart';
import '../models/governance_request_model.dart';

abstract class GovernanceDataSource {
  Future<List<GovernanceRequestModel>> getGovernanceRequests();

  Future<GovernanceRequestModel> signRequest({
    required String requestId,
    required String signerId,
    required String signerName,
    String? note,
  });

  Future<GovernanceRequestModel> rejectRequest({
    required String requestId,
    required String reason,
  });
}

class GovernanceDataSourceImpl implements GovernanceDataSource {
  List<GovernanceRequestModel>? _requests;

  void _initDefaults() {
    final now = DateTime.now();

    _requests = [
      GovernanceRequestModel(
        id: 'GOV-WIRE-2026-0881',
        title: 'Escrow Deposit: Zurich Tech M&A Acquisition',
        description:
            'Dual-control corporate authorization for 1st installment wire to Swiss legal escrow. Required under FINMA Dual-Control mandate.',
        amount: 450000.00,
        currency: 'USD',
        recipient: 'Baker McKenzie Zurich Escrow Client Account',
        recipientAddressOrIban: 'CH93 0076 2011 6238 5295 7',
        initiatedBy: 'Marc Oberholzer (VP Treasury Operations)',
        initiatedAt: now.subtract(const Duration(hours: 3, minutes: 12)),
        requiredSignatures: 3,
        totalSigners: 4,
        signers: [
          ApprovalSignerModel(
            id: 'SIGNER-CEO-01',
            name: 'Alexander Vance',
            role: 'Chief Executive Officer',
            hasApproved: true,
            signedAt: now.subtract(const Duration(hours: 2, minutes: 45)),
            signatureHash: '0x8f2a6b31c9d4e5f7a1b2c3d4e5f6a7b8c9d0e1f2',
          ),
          ApprovalSignerModel(
            id: 'SIGNER-CFO-02',
            name: 'Elena Rostova',
            role: 'Chief Financial Officer',
            hasApproved: true,
            signedAt: now.subtract(const Duration(minutes: 54)),
            signatureHash: '0x1c4d7e9a2b5f8c0d3e6f9a1b4c7d0e2f5a8b1c4d',
          ),
          ApprovalSignerModel(
            id: 'SIGNER-ARCHITECT-03',
            name: 'Pasindu Gayashan',
            role: 'Lead Architect & Key Custodian',
            hasApproved: false,
            signedAt: null,
            signatureHash: null,
          ),
          ApprovalSignerModel(
            id: 'SIGNER-COMPLIANCE-04',
            name: 'Claire Delacroix',
            role: 'FINMA Compliance Officer',
            hasApproved: false,
            signedAt: null,
            signatureHash: null,
          ),
        ],
        status: GovernanceStatus.pending,
        urgency: GovernanceUrgency.critical,
      ),
      GovernanceRequestModel(
        id: 'GOV-CRYPTO-2026-0419',
        title: 'Cold Vault Rebalancing: Anchorage to Validator',
        description:
            'Institutional transfer of 12.50 BTC cold reserve liquidity to Proof-of-Stake secondary yield buffer.',
        amount: 12.50,
        currency: 'BTC',
        recipient: 'AeroVault Zurich Cold Reserve Multi-Sig',
        recipientAddressOrIban: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
        initiatedBy: 'Kaspar Schmid (Head of Digital Assets)',
        initiatedAt: now.subtract(const Duration(hours: 14)),
        requiredSignatures: 2,
        totalSigners: 3,
        signers: [
          ApprovalSignerModel(
            id: 'SIGNER-CEO-01',
            name: 'Alexander Vance',
            role: 'Chief Executive Officer',
            hasApproved: true,
            signedAt: now.subtract(const Duration(hours: 8)),
            signatureHash: '0x3e7a9b1c5d8f0e2a4b6c8d0e1f3a5b7c9d1e3f5a',
          ),
          ApprovalSignerModel(
            id: 'SIGNER-ARCHITECT-03',
            name: 'Pasindu Gayashan',
            role: 'Lead Architect & Key Custodian',
            hasApproved: false,
            signedAt: null,
            signatureHash: null,
          ),
          ApprovalSignerModel(
            id: 'SIGNER-CFO-02',
            name: 'Elena Rostova',
            role: 'Chief Financial Officer',
            hasApproved: false,
            signedAt: null,
            signatureHash: null,
          ),
        ],
        status: GovernanceStatus.pending,
        urgency: GovernanceUrgency.elevated,
      ),
      GovernanceRequestModel(
        id: 'GOV-INFRA-2026-0112',
        title: 'Q4 Infrastructure Grant: AWS & Swiss Data Center',
        description:
            'Pre-authorized infrastructure settlement for Tier IV Zurich secure enclave cloud hosting operations.',
        amount: 84500.00,
        currency: 'USD',
        recipient: 'Amazon Web Services EMEA SARL',
        recipientAddressOrIban: 'LU12 0019 4006 4470 0001',
        initiatedBy: 'DevOps Automated Treasury Bot',
        initiatedAt: now.subtract(const Duration(days: 2)),
        requiredSignatures: 2,
        totalSigners: 3,
        signers: [
          ApprovalSignerModel(
            id: 'SIGNER-CFO-02',
            name: 'Elena Rostova',
            role: 'Chief Financial Officer',
            hasApproved: true,
            signedAt: now.subtract(const Duration(days: 1, hours: 22)),
            signatureHash: '0x4d8f1a3c6e9b2d5f0a7c4e8b1d3f6a9c2e5b8d1f',
          ),
          ApprovalSignerModel(
            id: 'SIGNER-ARCHITECT-03',
            name: 'Pasindu Gayashan',
            role: 'Lead Architect & Key Custodian',
            hasApproved: true,
            signedAt: now.subtract(const Duration(days: 1, hours: 20)),
            signatureHash: '0x9a2c5e8b1d4f7a0c3e6b9d2f5a8c1e4b7d0f3a6c',
          ),
          ApprovalSignerModel(
            id: 'SIGNER-CEO-01',
            name: 'Alexander Vance',
            role: 'Chief Executive Officer',
            hasApproved: false,
            signedAt: null,
            signatureHash: null,
          ),
        ],
        status: GovernanceStatus.executed,
        urgency: GovernanceUrgency.standard,
        executionTxHash: '0x7a89b41e21820b4299b67b37ccc8350fb8dce17a',
      ),
    ];
  }

  @override
  Future<List<GovernanceRequestModel>> getGovernanceRequests() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_requests == null) {
      _initDefaults();
    }
    return List.from(_requests!);
  }

  @override
  Future<GovernanceRequestModel> signRequest({
    required String requestId,
    required String signerId,
    required String signerName,
    String? note,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_requests == null) {
      _initDefaults();
    }

    final index = _requests!.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Governance request $requestId not found');
    }

    final req = _requests![index];
    final now = DateTime.now();

    final updatedSigners = req.signers.map((s) {
      if (s.id == signerId || s.name == signerName) {
        return ApprovalSignerModel(
          id: s.id,
          name: s.name,
          role: s.role,
          avatarUrl: s.avatarUrl,
          hasApproved: true,
          signedAt: now,
          signatureHash:
              '0x${now.millisecondsSinceEpoch.toRadixString(16)}8842${signerId.hashCode.abs().toRadixString(16)}',
        );
      }
      return ApprovalSignerModel.fromEntity(s);
    }).toList();

    final approvedCount = updatedSigners.where((s) => s.hasApproved).length;
    final isApprovedNow = approvedCount >= req.requiredSignatures;

    final updatedReq = GovernanceRequestModel(
      id: req.id,
      title: req.title,
      description: req.description,
      amount: req.amount,
      currency: req.currency,
      recipient: req.recipient,
      recipientAddressOrIban: req.recipientAddressOrIban,
      initiatedBy: req.initiatedBy,
      initiatedAt: req.initiatedAt,
      requiredSignatures: req.requiredSignatures,
      totalSigners: req.totalSigners,
      signers: updatedSigners,
      status: isApprovedNow ? GovernanceStatus.approved : req.status,
      urgency: req.urgency,
      rejectionReason: req.rejectionReason,
      executionTxHash: isApprovedNow
          ? '0x${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}f8842executed'
          : req.executionTxHash,
    );

    _requests![index] = updatedReq;
    return updatedReq;
  }

  @override
  Future<GovernanceRequestModel> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_requests == null) {
      _initDefaults();
    }

    final index = _requests!.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Governance request $requestId not found');
    }

    final req = _requests![index];
    final updatedReq = GovernanceRequestModel(
      id: req.id,
      title: req.title,
      description: req.description,
      amount: req.amount,
      currency: req.currency,
      recipient: req.recipient,
      recipientAddressOrIban: req.recipientAddressOrIban,
      initiatedBy: req.initiatedBy,
      initiatedAt: req.initiatedAt,
      requiredSignatures: req.requiredSignatures,
      totalSigners: req.totalSigners,
      signers: req.signers.map((s) => ApprovalSignerModel.fromEntity(s)).toList(),
      status: GovernanceStatus.rejected,
      urgency: req.urgency,
      rejectionReason: reason,
      executionTxHash: null,
    );

    _requests![index] = updatedReq;
    return updatedReq;
  }
}
