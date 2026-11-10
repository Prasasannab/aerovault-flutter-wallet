import 'package:equatable/equatable.dart';

enum KycDocumentStatus { verified, pending, expired }

class KycDocument extends Equatable {
  final String id;
  final String title;
  final String documentType;
  final String documentNumberMasked;
  final KycDocumentStatus status;
  final String verifiedDate;
  final String expiryDate;
  final String issuingAuthority;

  const KycDocument({
    required this.id,
    required this.title,
    required this.documentType,
    required this.documentNumberMasked,
    required this.status,
    required this.verifiedDate,
    required this.expiryDate,
    required this.issuingAuthority,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        documentType,
        documentNumberMasked,
        status,
        verifiedDate,
        expiryDate,
        issuingAuthority,
      ];
}
