import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthChecking extends AuthState {
  const AuthChecking();
}

class AuthAuthenticated extends AuthState {
  final String method; // 'PIN' or 'BIOMETRIC'
  const AuthAuthenticated({this.method = 'PIN'});

  @override
  List<Object?> get props => [method];
}

class AuthPinError extends AuthState {
  final String message;
  final int remainingAttempts;

  const AuthPinError({
    required this.message,
    required this.remainingAttempts,
  });

  @override
  List<Object?> get props => [message, remainingAttempts];
}

class AuthLockedOut extends AuthState {
  final String reason;
  const AuthLockedOut({
    this.reason = 'Maximum PIN attempts reached. Hardware Keystore session wiped.',
  });

  @override
  List<Object?> get props => [reason];
}
