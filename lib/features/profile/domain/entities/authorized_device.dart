import 'package:equatable/equatable.dart';

class AuthorizedDevice extends Equatable {
  final String id;
  final String deviceName;
  final String platform;
  final bool isCurrentDevice;
  final String lastActive;
  final String hardwareEnclaveType;
  final String ipAddressMasked;

  const AuthorizedDevice({
    required this.id,
    required this.deviceName,
    required this.platform,
    required this.isCurrentDevice,
    required this.lastActive,
    required this.hardwareEnclaveType,
    required this.ipAddressMasked,
  });

  @override
  List<Object?> get props => [
        id,
        deviceName,
        platform,
        isCurrentDevice,
        lastActive,
        hardwareEnclaveType,
        ipAddressMasked,
      ];
}
