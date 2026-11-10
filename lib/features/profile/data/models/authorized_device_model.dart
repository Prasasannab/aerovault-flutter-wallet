import '../../domain/entities/authorized_device.dart';

class AuthorizedDeviceModel extends AuthorizedDevice {
  const AuthorizedDeviceModel({
    required super.id,
    required super.deviceName,
    required super.platform,
    required super.isCurrentDevice,
    required super.lastActive,
    required super.hardwareEnclaveType,
    required super.ipAddressMasked,
  });

  factory AuthorizedDeviceModel.fromJson(Map<String, dynamic> json) {
    return AuthorizedDeviceModel(
      id: json['id'] as String,
      deviceName: json['device_name'] as String,
      platform: json['platform'] as String,
      isCurrentDevice: json['is_current_device'] as bool? ?? false,
      lastActive: json['last_active'] as String,
      hardwareEnclaveType: json['hardware_enclave_type'] as String,
      ipAddressMasked: json['ip_address_masked'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'platform': platform,
      'is_current_device': isCurrentDevice,
      'last_active': lastActive,
      'hardware_enclave_type': hardwareEnclaveType,
      'ip_address_masked': ipAddressMasked,
    };
  }
}
