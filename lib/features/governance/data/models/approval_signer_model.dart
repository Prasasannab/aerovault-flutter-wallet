import '../../domain/entities/approval_signer.dart';

class ApprovalSignerModel extends ApprovalSigner {
  const ApprovalSignerModel({
    required super.id,
    required super.name,
    required super.role,
    super.avatarUrl,
    required super.hasApproved,
    super.signedAt,
    super.signatureHash,
  });

  factory ApprovalSignerModel.fromEntity(ApprovalSigner entity) {
    return ApprovalSignerModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      avatarUrl: entity.avatarUrl,
      hasApproved: entity.hasApproved,
      signedAt: entity.signedAt,
      signatureHash: entity.signatureHash,
    );
  }

  factory ApprovalSignerModel.fromJson(Map<String, dynamic> json) {
    return ApprovalSignerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      hasApproved: json['has_approved'] as bool,
      signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at'] as String) : null,
      signatureHash: json['signature_hash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
      'has_approved': hasApproved,
      'signed_at': signedAt?.toIso8601String(),
      'signature_hash': signatureHash,
    };
  }
}
