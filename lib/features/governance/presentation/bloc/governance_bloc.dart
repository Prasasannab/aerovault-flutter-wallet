import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_governance_requests_use_case.dart';
import '../../domain/usecases/reject_governance_request_use_case.dart';
import '../../domain/usecases/sign_governance_request_use_case.dart';
import 'governance_event.dart';
import 'governance_state.dart';

class GovernanceBloc extends Bloc<GovernanceEvent, GovernanceState> {
  final GetGovernanceRequestsUseCase getGovernanceRequestsUseCase;
  final SignGovernanceRequestUseCase signGovernanceRequestUseCase;
  final RejectGovernanceRequestUseCase rejectGovernanceRequestUseCase;

  GovernanceBloc({
    required this.getGovernanceRequestsUseCase,
    required this.signGovernanceRequestUseCase,
    required this.rejectGovernanceRequestUseCase,
  }) : super(const GovernanceInitial()) {
    on<LoadGovernanceRequestsEvent>(_onLoadRequests);
    on<SignGovernanceRequestEvent>(_onSignRequest);
    on<RejectGovernanceRequestEvent>(_onRejectRequest);
    on<FilterGovernanceTabEvent>(_onFilterTab);
  }

  Future<void> _onLoadRequests(
    LoadGovernanceRequestsEvent event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(const GovernanceLoading());
    try {
      final requests = await getGovernanceRequestsUseCase();
      emit(GovernanceLoaded(requests: requests));
    } catch (e) {
      emit(GovernanceError('Failed to load corporate governance requests: $e'));
    }
  }

  Future<void> _onSignRequest(
    SignGovernanceRequestEvent event,
    Emitter<GovernanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GovernanceLoaded) return;

    try {
      final updated = await signGovernanceRequestUseCase(
        requestId: event.requestId,
        signerId: event.signerId,
        signerName: event.signerName,
        note: event.note,
      );

      final updatedList = currentState.requests.map((r) {
        return r.id == updated.id ? updated : r;
      }).toList();

      final statusMsg = updated.isReadyToExecute
          ? 'Corporate Dual-Control Authorization Complete! Wire broadcasted to Fedwire/SIC.'
          : 'Cryptographic Co-Signature appended successfully.';

      emit(currentState.copyWith(
        requests: updatedList,
        toastMessage: statusMsg,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        toastMessage: 'Failed to authorize signature: $e',
      ));
    }
  }

  Future<void> _onRejectRequest(
    RejectGovernanceRequestEvent event,
    Emitter<GovernanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GovernanceLoaded) return;

    try {
      final updated = await rejectGovernanceRequestUseCase(
        requestId: event.requestId,
        reason: event.reason,
      );

      final updatedList = currentState.requests.map((r) {
        return r.id == updated.id ? updated : r;
      }).toList();

      emit(currentState.copyWith(
        requests: updatedList,
        toastMessage: 'Corporate authorization vetoed. Recorded to audit trail.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        toastMessage: 'Failed to record veto: $e',
      ));
    }
  }

  void _onFilterTab(
    FilterGovernanceTabEvent event,
    Emitter<GovernanceState> emit,
  ) {
    if (state is GovernanceLoaded) {
      final loaded = state as GovernanceLoaded;
      emit(loaded.copyWith(selectedTab: event.tabIndex));
    }
  }
}
