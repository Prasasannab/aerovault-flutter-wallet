import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/governance_request.dart';
import 'multi_sig_progress_bar.dart';
import 'reject_request_sheet.dart';
import 'sign_authorization_sheet.dart';

class GovernanceRequestCard extends StatelessWidget {
  final GovernanceRequest request;

  const GovernanceRequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyFormatter = request.currency == 'USD'
        ? NumberFormat.currency(symbol: '\$', decimalDigits: 2)
        : NumberFormat('#,##0.0000');

    final currentUserApproved = request.hasSignerApproved('SIGNER-ARCHITECT-03');
    final isPending = request.status == GovernanceStatus.pending;
    final isExecuted = request.status == GovernanceStatus.executed;
    final isApproved = request.status == GovernanceStatus.approved;
    final isRejected = request.status == GovernanceStatus.rejected;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending && !currentUserApproved
              ? AppColors.warning.withValues(alpha: 0.45)
              : colors.border,
          width: isPending && !currentUserApproved ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Urgency chip & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUrgencyChip(request.urgency),
              _buildStatusBadge(request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.id,
            style: AppTextStyles.monospace(
              color: colors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // Title & Description
          Text(
            request.title,
            style: AppTextStyles.heading3(
              color: colors.textPrimary,
            ).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            request.description,
            style: AppTextStyles.bodySmall(
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 16),

          // Financial Detail Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PRINCIPAL',
                      style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5),
                    ),
                    Text(
                      request.currency == 'USD'
                          ? currencyFormatter.format(request.amount)
                          : '${currencyFormatter.format(request.amount)} ${request.currency}',
                      style: AppTextStyles.monospace(
                        color: AppColors.emerald,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: colors.border.withValues(alpha: 0.4), height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, size: 14, color: AppColors.emerald),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.recipient,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium(
                          color: colors.textPrimary,
                        ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: request.recipientAddressOrIban));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Beneficiary routing copied to clipboard',
                          style: AppTextStyles.bodySmall(color: Colors.white),
                        ),
                        backgroundColor: AppColors.surfaceElevated,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.copy_rounded, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          request.recipientAddressOrIban,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.monospace(
                            color: colors.textMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Multi-Sig Quorum Progress Component
          MultiSigProgressBar(request: request),

          const SizedBox(height: 18),

          // Action Section
          if (isPending) ...[
            if (currentUserApproved)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your cryptographic co-signature is appended. Awaiting final quorum execution.',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.emerald,
                        ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: BounceButton(
                      onTap: () => RejectRequestSheet.show(context, request),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.block, size: 14, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'Veto',
                              style: AppTextStyles.heading3(
                                color: AppColors.error,
                              ).copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BounceButton(
                      onTap: () => SignAuthorizationSheet.show(context, request),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.emeraldGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fingerprint_rounded, size: 16, color: Colors.black),
                            const SizedBox(width: 6),
                            Text(
                              'Review & Sign',
                              style: AppTextStyles.heading3(
                                color: Colors.black,
                              ).copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ] else if (isExecuted || isApproved) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.executionTxHash != null
                          ? 'Settled to Fedwire/SIC Interbank. Tx: ${request.executionTxHash}'
                          : 'Quorum Reached & Wire Cleared.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.monospace(
                        color: AppColors.emerald,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isRejected) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vetoed: ${request.rejectionReason ?? "Dual-control security cancellation"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall(
                        color: AppColors.error,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(GovernanceUrgency urgency) {
    Color color;
    String label;
    IconData icon;

    switch (urgency) {
      case GovernanceUrgency.critical:
        color = AppColors.error;
        label = 'CRITICAL DUAL-CONTROL';
        icon = Icons.priority_high_rounded;
        break;
      case GovernanceUrgency.elevated:
        color = AppColors.warning;
        label = 'ELEVATED MANDATE';
        icon = Icons.warning_amber_rounded;
        break;
      case GovernanceUrgency.standard:
        color = AppColors.info;
        label = 'STANDARD TREASURY';
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.label(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(GovernanceStatus status) {
    Color color;
    String label;

    switch (status) {
      case GovernanceStatus.pending:
        color = AppColors.warning;
        label = 'ACTION REQUIRED';
        break;
      case GovernanceStatus.approved:
        color = AppColors.emerald;
        label = 'QUORUM REACHED';
        break;
      case GovernanceStatus.executed:
        color = AppColors.emerald;
        label = 'SETTLED';
        break;
      case GovernanceStatus.rejected:
        color = AppColors.error;
        label = 'VETOED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
