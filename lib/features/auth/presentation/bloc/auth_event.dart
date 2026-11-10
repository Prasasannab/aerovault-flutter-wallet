import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class VerifyPinEvent extends AuthEvent {
  final String pin;
  const VerifyPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class BiometricAuthEvent extends AuthEvent {
  final String localizedReason;
  const BiometricAuthEvent({this.localizedReason = 'Authenticate with Face ID to unlock AeroVault'});

  @override
  List<Object?> get props => [localizedReason];
}

class ResetLockoutEvent extends AuthEvent {
  const ResetLockoutEvent();
}

class LockSessionEvent extends AuthEvent {
  const LockSessionEvent();
}
