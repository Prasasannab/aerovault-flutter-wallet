import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_use_case.dart';
import '../../domain/usecases/revoke_device_use_case.dart';
import '../../domain/usecases/update_transfer_limits_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateTransferLimitsUseCase updateTransferLimitsUseCase;
  final RevokeDeviceUseCase revokeDeviceUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateTransferLimitsUseCase,
    required this.revokeDeviceUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateLimitsEvent>(_onUpdateLimits);
    on<RevokeDeviceEvent>(_onRevokeDevice);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getUserProfileUseCase();
    result.fold(
      onSuccess: (profile) => emit(ProfileLoaded(profile: profile)),
      onError: (failure) => emit(ProfileError(failure.message)),
    );
  }

  Future<void> _onUpdateLimits(
    UpdateLimitsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final result = await updateTransferLimitsUseCase(
        dailyWireLimit: event.dailyWireLimit,
        monthlyCardCap: event.monthlyCardCap,
      );
      result.fold(
        onSuccess: (updatedProfile) => emit(
          ProfileLoaded(
            profile: updatedProfile,
            feedbackMessage: 'Banking limits updated and signed by Swiss clearing core',
          ),
        ),
        onError: (failure) => emit(ProfileError(failure.message)),
      );
    }
  }

  Future<void> _onRevokeDevice(
    RevokeDeviceEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final result = await revokeDeviceUseCase(event.deviceId);
      result.fold(
        onSuccess: (updatedProfile) => emit(
          ProfileLoaded(
            profile: updatedProfile,
            feedbackMessage: 'Device hardware enclave key revoked successfully',
          ),
        ),
        onError: (failure) => emit(ProfileError(failure.message)),
      );
    }
  }
}
