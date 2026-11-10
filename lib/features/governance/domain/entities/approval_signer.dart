import 'package:equatable/equatable.dart';

class ApprovalSigner extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final bool hasApproved;
  final DateTime? signedAt;
  final String? signatureHash;

  const ApprovalSigner({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.hasApproved,
    this.signedAt,
    this.signatureHash,
  });

  ApprovalSigner copyWith({
    String? id,
    String? name,
    String? role,
    String? avatarUrl,
    bool? hasApproved,
    DateTime? signedAt,
    String? signatureHash,
  }) {
    return ApprovalSigner(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasApproved: hasApproved ?? this.hasApproved,
      signedAt: signedAt ?? this.signedAt,
      signatureHash: signatureHash ?? this.signatureHash,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        avatarUrl,
        hasApproved,
        signedAt,
        signatureHash,
      ];
}
