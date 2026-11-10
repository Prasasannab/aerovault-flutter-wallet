import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateLimitsEvent extends ProfileEvent {
  final double dailyWireLimit;
  final double monthlyCardCap;

  const UpdateLimitsEvent({
    required this.dailyWireLimit,
    required this.monthlyCardCap,
  });

  @override
  List<Object?> get props => [dailyWireLimit, monthlyCardCap];
}

class RevokeDeviceEvent extends ProfileEvent {
  final String deviceId;

  const RevokeDeviceEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}
