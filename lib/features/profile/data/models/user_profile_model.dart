import '../../domain/entities/user_profile.dart';
import 'authorized_device_model.dart';
import 'kyc_document_model.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.preferredName,
    required super.email,
    required super.phoneMasked,
    required super.taxResidence,
    required super.clientTier,
    required super.finmaRegulated,
    required super.amlRiskScore,
    required super.dailyWireLimit,
    required super.dailyAtmLimit,
    required super.monthlyCardCap,
    required super.hardwareEnclaveKeyId,
    required super.biometricsEnabled,
    required super.documents,
    required super.authorizedDevices,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      preferredName: json['preferred_name'] as String,
      email: json['email'] as String,
      phoneMasked: json['phone_masked'] as String,
      taxResidence: json['tax_residence'] as String,
      clientTier: json['client_tier'] as String,
      finmaRegulated: json['finma_regulated'] as bool? ?? true,
      amlRiskScore: json['aml_risk_score'] as String,
      dailyWireLimit: (json['daily_wire_limit'] as num).toDouble(),
      dailyAtmLimit: (json['daily_atm_limit'] as num).toDouble(),
      monthlyCardCap: (json['monthly_card_cap'] as num).toDouble(),
      hardwareEnclaveKeyId: json['hardware_enclave_key_id'] as String,
      biometricsEnabled: json['biometrics_enabled'] as bool? ?? true,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => KycDocumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      authorizedDevices: (json['authorized_devices'] as List<dynamic>?)
              ?.map((e) => AuthorizedDeviceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'preferred_name': preferredName,
      'email': email,
      'phone_masked': phoneMasked,
      'tax_residence': taxResidence,
      'client_tier': clientTier,
      'finma_regulated': finmaRegulated,
      'aml_risk_score': amlRiskScore,
      'daily_wire_limit': dailyWireLimit,
      'daily_atm_limit': dailyAtmLimit,
      'monthly_card_cap': monthlyCardCap,
      'hardware_enclave_key_id': hardwareEnclaveKeyId,
      'biometrics_enabled': biometricsEnabled,
      'documents': documents
          .map((d) => (d is KycDocumentModel)
              ? d.toJson()
              : KycDocumentModel(
                  id: d.id,
                  title: d.title,
                  documentType: d.documentType,
                  documentNumberMasked: d.documentNumberMasked,
                  status: d.status,
                  verifiedDate: d.verifiedDate,
                  expiryDate: d.expiryDate,
                  issuingAuthority: d.issuingAuthority,
                ).toJson())
          .toList(),
      'authorized_devices': authorizedDevices
          .map((a) => (a is AuthorizedDeviceModel)
              ? a.toJson()
              : AuthorizedDeviceModel(
                  id: a.id,
                  deviceName: a.deviceName,
                  platform: a.platform,
                  isCurrentDevice: a.isCurrentDevice,
                  lastActive: a.lastActive,
                  hardwareEnclaveType: a.hardwareEnclaveType,
                  ipAddressMasked: a.ipAddressMasked,
                ).toJson())
          .toList(),
    };
  }
}
