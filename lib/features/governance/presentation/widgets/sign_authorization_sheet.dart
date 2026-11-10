import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/governance_request.dart';
import '../bloc/governance_bloc.dart';
import '../bloc/governance_event.dart';

class SignAuthorizationSheet extends StatefulWidget {
  final GovernanceRequest request;

  const SignAuthorizationSheet({super.key, required this.request});

  static Future<void> show(BuildContext context, GovernanceRequest request) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<GovernanceBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: SignAuthorizationSheet(request: request),
      ),
    );
  }

  @override
  State<SignAuthorizationSheet> createState() => _SignAuthorizationSheetState();
}

class _SignAuthorizationSheetState extends State<SignAuthorizationSheet> {
  bool _isSigning = false;

  Future<void> _handleAuthorize() async {
    setState(() {
      _isSigning = true;
    });

    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    context.read<GovernanceBloc>().add(
          SignGovernanceRequestEvent(
            requestId: widget.request.id,
            signerId: 'SIGNER-ARCHITECT-03',
            signerName: 'Pasindu Gayashan',
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final req = widget.request;
    final currencyFormatter = req.currency == 'USD'
        ? NumberFormat.currency(symbol: '\$', decimalDigits: 2)
        : NumberFormat('#,##0.0000');

    final willExecute = (req.approvedCount + 1) >= req.requiredSignatures;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColors.emerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DUAL-CONTROL HARDWARE AUTHORIZATION',
                        style: AppTextStyles.label(
                          color: AppColors.emerald,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        req.id,
                        style: AppTextStyles.heading3(
                          color: colors.textPrimary,
                        ).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'FINMA ART. 47',
                    style: AppTextStyles.label(
                      color: AppColors.emerald,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Transaction Details Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AUTHORIZATION AMOUNT',
                        style: AppTextStyles.label(color: colors.textMuted, fontSize: 10),
                      ),
                      Text(
                        req.currency == 'USD'
                            ? currencyFormatter.format(req.amount)
                            : '${currencyFormatter.format(req.amount)} ${req.currency}',
                        style: AppTextStyles.monospace(
                          color: AppColors.emerald,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Beneficiary',
                    value: req.recipient,
                    colors: colors,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    label: req.currency == 'USD' ? 'Target IBAN' : 'Target Address',
                    value: req.recipientAddressOrIban,
                    colors: colors,
                    isMonospace: true,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    label: 'Initiated By',
                    value: req.initiatedBy,
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hardware Enclave Telemetry Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceElevated.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fingerprint_rounded, size: 16, color: AppColors.emerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hardware Enclave Key Custody',
                          style: AppTextStyles.label(
                            color: colors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'SEC-ENCLAVE-ED25519-8842-CH (Pasindu G.)',
                          style: AppTextStyles.monospace(
                            color: colors.textMuted,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_rounded, size: 14, color: AppColors.emerald),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quorum Resolution Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: willExecute
                    ? AppColors.emerald.withValues(alpha: 0.1)
                    : colors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: willExecute
                      ? AppColors.emerald.withValues(alpha: 0.3)
                      : colors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    willExecute ? Icons.bolt_rounded : Icons.info_outline_rounded,
                    size: 16,
                    color: willExecute ? AppColors.emerald : colors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      willExecute
                          ? 'This signature fulfills the final quorum (${req.approvedCount + 1}/${req.requiredSignatures}). The wire will instantly broadcast to Fedwire/SIC.'
                          : 'Signing will record signature ${req.approvedCount + 1} of ${req.requiredSignatures}. Awaiting 1 additional executive co-sign.',
                      style: AppTextStyles.bodySmall(
                        color: willExecute ? AppColors.emerald : colors.textMuted,
                      ).copyWith(fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: BounceButton(
                    onTap: _isSigning ? null : () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.heading3(color: colors.textPrimary)
                            .copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BounceButton(
                    onTap: _isSigning ? null : _handleAuthorize,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppColors.emeraldGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isSigning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fingerprint_rounded, size: 18, color: Colors.black),
                                const SizedBox(width: 6),
                                Text(
                                  'Face ID Co-Sign',
                                  style: AppTextStyles.heading3(color: Colors.black)
                                      .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final dynamic colors;
  final bool isMonospace;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: colors.textMuted),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isMonospace
                ? AppTextStyles.monospace(
                    color: colors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.bodyMedium(
                    color: colors.textPrimary,
                  ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
