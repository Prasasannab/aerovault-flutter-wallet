import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/payment_card.dart';

class CardSpendingSliderWidget extends StatefulWidget {
  final PaymentCard card;
  final ValueChanged<double> onLimitChanged;

  const CardSpendingSliderWidget({
    super.key,
    required this.card,
    required this.onLimitChanged,
  });

  @override
  State<CardSpendingSliderWidget> createState() => _CardSpendingSliderWidgetState();
}

class _CardSpendingSliderWidgetState extends State<CardSpendingSliderWidget> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.card.spendingLimit;
  }

  @override
  void didUpdateWidget(covariant CardSpendingSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.spendingLimit != oldWidget.card.spendingLimit) {
      _currentSliderValue = widget.card.spendingLimit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spendPercentage = widget.card.spendPercentage;
    final remaining = widget.card.remainingLimit;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY SPENDING BUDGET',
                style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '\$${_currentSliderValue.toStringAsFixed(0)} Cap',
                  style: AppTextStyles.monospace(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Spend vs Limit Readout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent this cycle',
                    style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${widget.card.currentSpend.toStringAsFixed(2)}',
                    style: AppTextStyles.heading3(color: colors.textPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining headroom',
                    style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${remaining.toStringAsFixed(2)}',
                    style: AppTextStyles.heading3(
                      color: remaining < 1000 ? const Color(0xFFEF4444) : colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: spendPercentage,
              minHeight: 8,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                spendPercentage > 0.85
                    ? const Color(0xFFEF4444)
                    : (spendPercentage > 0.65 ? const Color(0xFFF59E0B) : colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.border,
              thumbColor: colors.primary,
              overlayColor: colors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: _currentSliderValue.clamp(1000.0, 100000.0),
              min: 1000.0,
              max: 100000.0,
              divisions: 99,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentSliderValue = val;
                });
              },
              onChangeEnd: (val) {
                HapticFeedback.mediumImpact();
                widget.onLimitChanged(val);
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$1,000', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9)),
              Text('\$50,000', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9)),
              Text('\$100,000', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
