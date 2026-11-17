import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/kyc_document.dart';
import '../models/authorized_device_model.dart';
import '../models/kyc_document_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateLimits({
    required double dailyWireLimit,
    required double monthlyCardCap,
  });
  Future<UserProfileModel> revokeDevice(String deviceId);
}

class ProfileLocalDataSourceImpl implements ProfileDataSource {
  UserProfileModel? _cachedProfile;

  UserProfileModel _buildDefaultProfile() {
    return const UserProfileModel(
      id: 'USR-8842-ENTERPRISE',
      fullName: 'Prasanna Buddhika',
      preferredName: 'Prasanna',
      email: 'pasindu.g@aerovault.swiss',
      phoneMasked: '+41 79 ••• •• 42',
      taxResidence: 'Zurich, Switzerland (CH)',
      clientTier: 'Tier 3 Sovereign Private',
      finmaRegulated: true,
      amlRiskScore: 'Ultra-Low (0.01) • Zero Sanctions Flag',
      dailyWireLimit: 500000.0,
      dailyAtmLimit: 10000.0,
      monthlyCardCap: 100000.0,
      hardwareEnclaveKeyId: 'SEC-ENCLAVE-ED25519-8842-CH',
      biometricsEnabled: true,
      documents: [
        KycDocumentModel(
          id: 'DOC-CH-PASS-8842',
          title: 'Swiss Biometric Passport',
          documentType: 'Government Passport',
          documentNumberMasked: 'PA••••8842',
          status: KycDocumentStatus.verified,
          verifiedDate: '14 Oct 2024',
          expiryDate: '14 Oct 2034',
          issuingAuthority: 'Swiss Federal Dept. of Foreign Affairs (EDA)',
        ),
        KycDocumentModel(
          id: 'DOC-CH-RES-9182',
          title: 'Canton Zurich Certificate of Residence',
          documentType: 'Proof of Address',
          documentNumberMasked: 'ZH••••9182',
          status: KycDocumentStatus.verified,
          verifiedDate: '02 Jan 2026',
          expiryDate: '02 Jan 2027',
          issuingAuthority: 'Kanton Zürich Einwohnerkontrolle',
        ),
        KycDocumentModel(
          id: 'DOC-FATCA-W8BEN',
          title: 'W-8BEN Institutional Tax Compliance',
          documentType: 'Cross-Border Tax Treaty',
          documentNumberMasked: 'W8••••4102',
          status: KycDocumentStatus.verified,
          verifiedDate: '15 Jan 2026',
          expiryDate: '31 Dec 2028',
          issuingAuthority: 'IRS & Swiss Federal Tax Admin (ESTV)',
        ),
        KycDocumentModel(
          id: 'DOC-AML-WEALTH',
          title: 'Origin of Wealth Verification',
          documentType: 'AML / Sovereign Source of Funds',
          documentNumberMasked: 'AML••••7719',
          status: KycDocumentStatus.verified,
          verifiedDate: '10 Feb 2026',
          expiryDate: 'Lifetime Audit Exemption',
          issuingAuthority: 'PwC Private Banking Assurance Geneva',
        ),
      ],
      authorizedDevices: [
        AuthorizedDeviceModel(
          id: 'DEV-IPHONE-16-PRO',
          deviceName: 'iPhone 16 Pro (This Device)',
          platform: 'iOS 18.2 • Secure Enclave A18 Pro',
          isCurrentDevice: true,
          lastActive: 'Active Now',
          hardwareEnclaveType: 'Hardware TEE / Apple Enclave Level 3',
          ipAddressMasked: '194.230.•••.12 (Zurich, CH)',
        ),
        AuthorizedDeviceModel(
          id: 'DEV-MBP-M3-MAX',
          deviceName: 'MacBook Pro M3 Max',
          platform: 'macOS Sequoia 15.3 • Touch ID Enclave',
          isCurrentDevice: false,
          lastActive: '2 hours ago',
          hardwareEnclaveType: 'Apple M3 Silicon Hardware Root',
          ipAddressMasked: '194.230.•••.12 (Zurich, CH)',
        ),
      ],
    );
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    _cachedProfile ??= _buildDefaultProfile();
    return _cachedProfile!;
  }

  @override
  Future<UserProfileModel> updateLimits({
    required double dailyWireLimit,
    required double monthlyCardCap,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    _cachedProfile ??= _buildDefaultProfile();
    _cachedProfile = _cachedProfile!.copyWith(
      dailyWireLimit: dailyWireLimit,
      monthlyCardCap: monthlyCardCap,
    ) as UserProfileModel;
    return _cachedProfile!;
  }

  @override
  Future<UserProfileModel> revokeDevice(String deviceId) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    _cachedProfile ??= _buildDefaultProfile();
    final updatedDevices = _cachedProfile!.authorizedDevices
        .where((d) => d.id != deviceId)
        .toList();

    _cachedProfile = UserProfileModel(
      id: _cachedProfile!.id,
      fullName: _cachedProfile!.fullName,
      preferredName: _cachedProfile!.preferredName,
      email: _cachedProfile!.email,
      phoneMasked: _cachedProfile!.phoneMasked,
      taxResidence: _cachedProfile!.taxResidence,
      clientTier: _cachedProfile!.clientTier,
      finmaRegulated: _cachedProfile!.finmaRegulated,
      amlRiskScore: _cachedProfile!.amlRiskScore,
      dailyWireLimit: _cachedProfile!.dailyWireLimit,
      dailyAtmLimit: _cachedProfile!.dailyAtmLimit,
      monthlyCardCap: _cachedProfile!.monthlyCardCap,
      hardwareEnclaveKeyId: _cachedProfile!.hardwareEnclaveKeyId,
      biometricsEnabled: _cachedProfile!.biometricsEnabled,
      documents: _cachedProfile!.documents,
      authorizedDevices: updatedDevices,
    );
    return _cachedProfile!;
  }
}
