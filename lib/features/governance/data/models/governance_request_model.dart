import '../../domain/entities/governance_request.dart';
import 'approval_signer_model.dart';

class GovernanceRequestModel extends GovernanceRequest {
  const GovernanceRequestModel({
    required super.id,
    required super.title,
    required super.description,
    required super.amount,
    required super.currency,
    required super.recipient,
    required super.recipientAddressOrIban,
    required super.initiatedBy,
    required super.initiatedAt,
    required super.requiredSignatures,
    required super.totalSigners,
    required super.signers,
    required super.status,
    required super.urgency,
    super.rejectionReason,
    super.executionTxHash,
  });

  factory GovernanceRequestModel.fromEntity(GovernanceRequest entity) {
    return GovernanceRequestModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      amount: entity.amount,
      currency: entity.currency,
      recipient: entity.recipient,
      recipientAddressOrIban: entity.recipientAddressOrIban,
      initiatedBy: entity.initiatedBy,
      initiatedAt: entity.initiatedAt,
      requiredSignatures: entity.requiredSignatures,
      totalSigners: entity.totalSigners,
      signers: entity.signers,
      status: entity.status,
      urgency: entity.urgency,
      rejectionReason: entity.rejectionReason,
      executionTxHash: entity.executionTxHash,
    );
  }

  factory GovernanceRequestModel.fromJson(Map<String, dynamic> json) {
    return GovernanceRequestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      recipient: json['recipient'] as String,
      recipientAddressOrIban: json['recipient_address_or_iban'] as String,
      initiatedBy: json['initiated_by'] as String,
      initiatedAt: DateTime.parse(json['initiated_at'] as String),
      requiredSignatures: json['required_signatures'] as int,
      totalSigners: json['total_signers'] as int,
      signers: (json['signers'] as List)
          .map((s) => ApprovalSignerModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      status: GovernanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GovernanceStatus.pending,
      ),
      urgency: GovernanceUrgency.values.firstWhere(
        (e) => e.name == json['urgency'],
        orElse: () => GovernanceUrgency.standard,
      ),
      rejectionReason: json['rejection_reason'] as String?,
      executionTxHash: json['execution_tx_hash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'recipient': recipient,
      'recipient_address_or_iban': recipientAddressOrIban,
      'initiated_by': initiatedBy,
      'initiated_at': initiatedAt.toIso8601String(),
      'required_signatures': requiredSignatures,
      'total_signers': totalSigners,
      'signers': signers.map((s) {
        if (s is ApprovalSignerModel) return s.toJson();
        return ApprovalSignerModel.fromEntity(s).toJson();
      }).toList(),
      'status': status.name,
      'urgency': urgency.name,
      'rejection_reason': rejectionReason,
      'execution_tx_hash': executionTxHash,
    };
  }
}
