import '../../domain/entities/kyc_document.dart';

class KycDocumentModel extends KycDocument {
  const KycDocumentModel({
    required super.id,
    required super.title,
    required super.documentType,
    required super.documentNumberMasked,
    required super.status,
    required super.verifiedDate,
    required super.expiryDate,
    required super.issuingAuthority,
  });

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      documentType: json['document_type'] as String,
      documentNumberMasked: json['document_number_masked'] as String,
      status: KycDocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => KycDocumentStatus.verified,
      ),
      verifiedDate: json['verified_date'] as String,
      expiryDate: json['expiry_date'] as String,
      issuingAuthority: json['issuing_authority'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'document_type': documentType,
      'document_number_masked': documentNumberMasked,
      'status': status.name,
      'verified_date': verifiedDate,
      'expiry_date': expiryDate,
      'issuing_authority': issuingAuthority,
    };
  }
}
