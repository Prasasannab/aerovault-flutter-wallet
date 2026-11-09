import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Timeframe Switcher ([1W] [1M] [1Y] [ALL]) with animated pill indicators
class TimeframeSelectorWidget extends StatelessWidget {
  final String activeTimeframe;
  final ValueChanged<String> onSelectTimeframe;

  const TimeframeSelectorWidget({
    super.key,
    required this.activeTimeframe,
    required this.onSelectTimeframe,
  });

  static const List<String> timeframes = ['1W', '1M', '1Y', 'ALL'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: timeframes.map((tf) {
          final isSelected = tf == activeTimeframe;
          return BounceButton(
            scaleAmount: 0.95,
            onTap: () {
              if (!isSelected) {
                HapticFeedback.selectionClick();
                onSelectTimeframe(tf);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.emerald : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.emeraldGlow,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                tf,
                style: AppTextStyles.label(
                  color: isSelected ? AppColors.background : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
