import 'package:equatable/equatable.dart';
import 'authorized_device.dart';
import 'kyc_document.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String preferredName;
  final String email;
  final String phoneMasked;
  final String taxResidence;
  final String clientTier;
  final bool finmaRegulated;
  final String amlRiskScore;
  final double dailyWireLimit;
  final double dailyAtmLimit;
  final double monthlyCardCap;
  final String hardwareEnclaveKeyId;
  final bool biometricsEnabled;
  final List<KycDocument> documents;
  final List<AuthorizedDevice> authorizedDevices;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.preferredName,
    required this.email,
    required this.phoneMasked,
    required this.taxResidence,
    required this.clientTier,
    required this.finmaRegulated,
    required this.amlRiskScore,
    required this.dailyWireLimit,
    required this.dailyAtmLimit,
    required this.monthlyCardCap,
    required this.hardwareEnclaveKeyId,
    required this.biometricsEnabled,
    required this.documents,
    required this.authorizedDevices,
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? preferredName,
    String? email,
    String? phoneMasked,
    String? taxResidence,
    String? clientTier,
    bool? finmaRegulated,
    String? amlRiskScore,
    double? dailyWireLimit,
    double? dailyAtmLimit,
    double? monthlyCardCap,
    String? hardwareEnclaveKeyId,
    bool? biometricsEnabled,
    List<KycDocument>? documents,
    List<AuthorizedDevice>? authorizedDevices,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      preferredName: preferredName ?? this.preferredName,
      email: email ?? this.email,
      phoneMasked: phoneMasked ?? this.phoneMasked,
      taxResidence: taxResidence ?? this.taxResidence,
      clientTier: clientTier ?? this.clientTier,
      finmaRegulated: finmaRegulated ?? this.finmaRegulated,
      amlRiskScore: amlRiskScore ?? this.amlRiskScore,
      dailyWireLimit: dailyWireLimit ?? this.dailyWireLimit,
      dailyAtmLimit: dailyAtmLimit ?? this.dailyAtmLimit,
      monthlyCardCap: monthlyCardCap ?? this.monthlyCardCap,
      hardwareEnclaveKeyId: hardwareEnclaveKeyId ?? this.hardwareEnclaveKeyId,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      documents: documents ?? this.documents,
      authorizedDevices: authorizedDevices ?? this.authorizedDevices,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        preferredName,
        email,
        phoneMasked,
        taxResidence,
        clientTier,
        finmaRegulated,
        amlRiskScore,
        dailyWireLimit,
        dailyAtmLimit,
        monthlyCardCap,
        hardwareEnclaveKeyId,
        biometricsEnabled,
        documents,
        authorizedDevices,
      ];
}
