import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/governance_request.dart';
import '../bloc/governance_bloc.dart';
import '../bloc/governance_event.dart';

class RejectRequestSheet extends StatefulWidget {
  final GovernanceRequest request;

  const RejectRequestSheet({super.key, required this.request});

  static Future<void> show(BuildContext context, GovernanceRequest request) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<GovernanceBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: RejectRequestSheet(request: request),
      ),
    );
  }

  @override
  State<RejectRequestSheet> createState() => _RejectRequestSheetState();
}

class _RejectRequestSheetState extends State<RejectRequestSheet> {
  final TextEditingController _reasonController = TextEditingController(
    text: 'Out-of-band beneficiary re-verification required.',
  );

  final List<String> _presetReasons = [
    'Out-of-band beneficiary re-verification required',
    'Exceeds authorized daily treasury threshold',
    'Suspicious routing or unverified escrow address',
    'Awaiting secondary FinCEN/FINMA clearance',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(22, 16, 22, 24 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.block_flipped,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VETO CORPORATE AUTHORIZATION',
                        style: AppTextStyles.label(
                          color: AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.request.id,
                        style: AppTextStyles.heading3(
                          color: colors.textPrimary,
                        ).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Exercising a dual-control veto will immediately cancel this wire and log a permanent compliance audit notice across all key custodian hardware nodes.',
              style: AppTextStyles.bodySmall(color: colors.textMuted),
            ),
            const SizedBox(height: 16),

            Text(
              'SELECT VETO REASON',
              style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _presetReasons.map((preset) {
                final isSelected = _reasonController.text == preset;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _reasonController.text = preset;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.error.withValues(alpha: 0.15)
                          : colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.error.withValues(alpha: 0.4)
                            : colors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      preset,
                      style: AppTextStyles.bodySmall(
                        color: isSelected ? AppColors.error : colors.textMuted,
                      ).copyWith(fontSize: 10.5),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _reasonController,
              maxLines: 2,
              style: AppTextStyles.bodyMedium(color: colors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceElevated,
                hintText: 'Enter specific justification for FINMA audit record...',
                hintStyle: AppTextStyles.bodySmall(color: colors.textMuted),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: BounceButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Dismiss',
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
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      context.read<GovernanceBloc>().add(
                            RejectGovernanceRequestEvent(
                              requestId: widget.request.id,
                              reason: _reasonController.text.trim(),
                            ),
                          );
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.block, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Execute Veto',
                            style: AppTextStyles.heading3(color: Colors.white)
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
