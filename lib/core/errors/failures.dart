import 'package:equatable/equatable.dart';

/// Base Failure class for Clean Architecture domain layer
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server & Remote API failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    String message = 'A remote banking server error occurred. Please try again.',
    this.statusCode,
    String? code,
  }) : super(message, code: code);

  @override
  List<Object?> get props => [message, statusCode, code];
}

/// Local storage & Keystore failures
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Secure storage access failure.',
    String? code,
  }) : super(message, code: code);
}

/// Security failures (SSL MITM, Integrity tampering)
class SecurityFailure extends Failure {
  const SecurityFailure({
    required String message,
    String? code,
  }) : super(message, code: code);
}

/// Biometric authentication failures
class BiometricFailure extends Failure {
  const BiometricFailure({
    required String message,
    String? code,
  }) : super(message, code: code);
}

/// PIN authentication failures
class PinAuthFailure extends Failure {
  final int attemptsRemaining;

  const PinAuthFailure({
    required String message,
    this.attemptsRemaining = 0,
    String? code,
  }) : super(message, code: code);

  @override
  List<Object?> get props => [message, attemptsRemaining, code];
}

/// Device integrity compromise failure (Jailbreak, Root, Tampering)
class DeviceCompromisedFailure extends Failure {
  final List<String> compromiseReasons;

  const DeviceCompromisedFailure({
    required String message,
    required this.compromiseReasons,
    String? code,
  }) : super(message, code: code);

  @override
  List<Object?> get props => [message, compromiseReasons, code];
}
