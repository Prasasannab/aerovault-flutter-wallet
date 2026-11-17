import 'package:equatable/equatable.dart';

abstract class GovernanceEvent extends Equatable {
  const GovernanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadGovernanceRequestsEvent extends GovernanceEvent {
  const LoadGovernanceRequestsEvent();
}

class SignGovernanceRequestEvent extends GovernanceEvent {
  final String requestId;
  final String signerId;
  final String signerName;
  final String? note;

  const SignGovernanceRequestEvent({
    required this.requestId,
    this.signerId = 'SIGNER-ARCHITECT-03',
    this.signerName = 'Prasanna Buddhika',
    this.note,
  });

  @override
  List<Object?> get props => [requestId, signerId, signerName, note];
}

class RejectGovernanceRequestEvent extends GovernanceEvent {
  final String requestId;
  final String reason;

  const RejectGovernanceRequestEvent({
    required this.requestId,
    required this.reason,
  });

  @override
  List<Object?> get props => [requestId, reason];
}

class FilterGovernanceTabEvent extends GovernanceEvent {
  final int tabIndex; // 0: Action Required, 1: Audit History

  const FilterGovernanceTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
