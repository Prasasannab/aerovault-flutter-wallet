import 'package:equatable/equatable.dart';
import '../../domain/entities/governance_request.dart';

abstract class GovernanceState extends Equatable {
  const GovernanceState();

  @override
  List<Object?> get props => [];
}

class GovernanceInitial extends GovernanceState {
  const GovernanceInitial();
}

class GovernanceLoading extends GovernanceState {
  const GovernanceLoading();
}

class GovernanceLoaded extends GovernanceState {
  final List<GovernanceRequest> requests;
  final int selectedTab; // 0: Pending / Action Required, 1: Executed / History
  final String? toastMessage;

  const GovernanceLoaded({
    required this.requests,
    this.selectedTab = 0,
    this.toastMessage,
  });

  List<GovernanceRequest> get pendingRequests =>
      requests.where((r) => r.status == GovernanceStatus.pending).toList();

  List<GovernanceRequest> get historyRequests =>
      requests.where((r) => r.status != GovernanceStatus.pending).toList();

  int get pendingCount => pendingRequests.length;

  GovernanceLoaded copyWith({
    List<GovernanceRequest>? requests,
    int? selectedTab,
    String? toastMessage,
  }) {
    return GovernanceLoaded(
      requests: requests ?? this.requests,
      selectedTab: selectedTab ?? this.selectedTab,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [requests, selectedTab, toastMessage];
}

class GovernanceError extends GovernanceState {
  final String message;

  const GovernanceError(this.message);

  @override
  List<Object?> get props => [message];
}
