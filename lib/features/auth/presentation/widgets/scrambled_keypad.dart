import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Bank-Grade Scrambled Numeric Keypad
/// Digit order is pseudo-randomized to prevent shoulder-surfing and touchscreen smudge tracing.
class ScrambledKeypad extends StatelessWidget {
  final List<int> digits;
  final ValueChanged<int> onDigitTap;
  final VoidCallback onBackspace;
  final VoidCallback onBiometricTap;
  final VoidCallback onShuffleTap;
  final bool isScrambled;

  const ScrambledKeypad({
    super.key,
    required this.digits,
    required this.onDigitTap,
    required this.onBackspace,
    required this.onBiometricTap,
    required this.onShuffleTap,
    this.isScrambled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Digits grid layout: 3 rows of 3, plus 1 bottom row (Biometric, 10th digit, Backspace)
    final row1 = digits.sublist(0, 3);
    final row2 = digits.sublist(3, 6);
    final row3 = digits.sublist(6, 9);
    final lastDigit = digits[9];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shuffle & Security Indicator Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onShuffleTap();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isScrambled ? colors.primary.withValues(alpha: 0.5) : colors.cardBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shuffle_rounded,
                    size: 14,
                    color: isScrambled ? colors.primary : colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isScrambled ? 'Anti-Spy Scramble Active • Tap to Reshuffle' : 'Standard Keypad Active',
                    style: AppTextStyles.label(
                      color: isScrambled ? colors.primary : colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Keypad Grid
        _buildRow(context, row1),
        const SizedBox(height: 12),
        _buildRow(context, row2),
        const SizedBox(height: 12),
        _buildRow(context, row3),
        const SizedBox(height: 12),
        _buildBottomRow(context, lastDigit),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<int> rowDigits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowDigits.map((digit) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildDigitButton(context, digit),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context, int lastDigit) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left: Face ID / Biometrics
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BounceButton(
            onTap: () {
              HapticFeedback.lightImpact();
              onBiometricTap();
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.fingerprint_rounded,
                color: colors.primary,
                size: 32,
              ),
            ),
          ),
        ),

        // Center: 10th Scrambled Digit
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildDigitButton(context, lastDigit),
        ),

        // Right: Backspace
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BounceButton(
            onTap: () {
              HapticFeedback.selectionClick();
              onBackspace();
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(
                  color: colors.cardBorder.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.backspace_outlined,
                color: colors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitButton(BuildContext context, int digit) {
    final colors = context.colors;

    return BounceButton(
      onTap: () {
        HapticFeedback.selectionClick();
        onDigitTap(digit);
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(
            color: colors.cardBorder.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          digit.toString(),
          style: AppTextStyles.heading1(color: colors.textPrimary).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
