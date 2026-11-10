import 'package:equatable/equatable.dart';
import 'approval_signer.dart';

enum GovernanceStatus { pending, approved, rejected, executed }

enum GovernanceUrgency { standard, elevated, critical }

class GovernanceRequest extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final String recipient;
  final String recipientAddressOrIban;
  final String initiatedBy;
  final DateTime initiatedAt;
  final int requiredSignatures;
  final int totalSigners;
  final List<ApprovalSigner> signers;
  final GovernanceStatus status;
  final GovernanceUrgency urgency;
  final String? rejectionReason;
  final String? executionTxHash;

  const GovernanceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    required this.recipient,
    required this.recipientAddressOrIban,
    required this.initiatedBy,
    required this.initiatedAt,
    required this.requiredSignatures,
    required this.totalSigners,
    required this.signers,
    required this.status,
    required this.urgency,
    this.rejectionReason,
    this.executionTxHash,
  });

  int get approvedCount => signers.where((s) => s.hasApproved).length;

  bool get isReadyToExecute => approvedCount >= requiredSignatures;

  bool hasSignerApproved(String signerId) {
    return signers.any((s) => s.id == signerId && s.hasApproved);
  }

  GovernanceRequest copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? currency,
    String? recipient,
    String? recipientAddressOrIban,
    String? initiatedBy,
    DateTime? initiatedAt,
    int? requiredSignatures,
    int? totalSigners,
    List<ApprovalSigner>? signers,
    GovernanceStatus? status,
    GovernanceUrgency? urgency,
    String? rejectionReason,
    String? executionTxHash,
  }) {
    return GovernanceRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recipient: recipient ?? this.recipient,
      recipientAddressOrIban: recipientAddressOrIban ?? this.recipientAddressOrIban,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      requiredSignatures: requiredSignatures ?? this.requiredSignatures,
      totalSigners: totalSigners ?? this.totalSigners,
      signers: signers ?? this.signers,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      executionTxHash: executionTxHash ?? this.executionTxHash,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        currency,
        recipient,
        recipientAddressOrIban,
        initiatedBy,
        initiatedAt,
        requiredSignatures,
        totalSigners,
        signers,
        status,
        urgency,
        rejectionReason,
        executionTxHash,
      ];
}
