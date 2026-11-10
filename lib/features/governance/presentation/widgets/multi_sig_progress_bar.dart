import 'package:flutter/material.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/governance_request.dart';

class MultiSigProgressBar extends StatelessWidget {
  final GovernanceRequest request;

  const MultiSigProgressBar({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final approvedCount = request.approvedCount;
    final requiredCount = request.requiredSignatures;
    final isApproved = approvedCount >= requiredCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isApproved ? Icons.verified_rounded : Icons.vpn_key_outlined,
                  size: 14,
                  color: isApproved ? AppColors.emerald : AppColors.warning,
                ),
                const SizedBox(width: 5),
                Text(
                  'MULTI-SIG QUORUM: $approvedCount OF $requiredCount REQUIRED',
                  style: AppTextStyles.label(
                    color: isApproved ? AppColors.emerald : AppColors.warning,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isApproved ? AppColors.emerald : AppColors.warning)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${(approvedCount / requiredCount * 100).clamp(0, 100).toInt()}% Quorum',
                style: AppTextStyles.monospace(
                  color: isApproved ? AppColors.emerald : AppColors.warning,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stepped Quorum Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: List.generate(request.requiredSignatures, (index) {
                final isStepSigned = index < approvedCount;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < request.requiredSignatures - 1 ? 4 : 0,
                    ),
                    color: isStepSigned
                        ? AppColors.emerald
                        : colors.border.withValues(alpha: 0.8),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Signers List Chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: request.signers.map((signer) {
            final isSigned = signer.hasApproved;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSigned
                    ? AppColors.emerald.withValues(alpha: 0.1)
                    : colors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSigned
                      ? AppColors.emerald.withValues(alpha: 0.35)
                      : colors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSigned ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                    size: 12,
                    color: isSigned ? AppColors.emerald : colors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    signer.name,
                    style: AppTextStyles.bodySmall(
                      color: isSigned ? colors.textPrimary : colors.textMuted,
                    ).copyWith(
                      fontSize: 10.5,
                      fontWeight: isSigned ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
