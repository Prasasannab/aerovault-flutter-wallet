import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/aerovault_colors.dart';

/// 6 Cryptographic PIN Indicator Dots with Micro-Animations & Error Shake
class PinDotsIndicator extends StatefulWidget {
  final int pinLength;
  final int maxDigits;
  final bool hasError;

  const PinDotsIndicator({
    super.key,
    required this.pinLength,
    this.maxDigits = 6,
    this.hasError = false,
  });

  @override
  State<PinDotsIndicator> createState() => _PinDotsIndicatorState();
}

class _PinDotsIndicatorState extends State<PinDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    // 250ms purposeful error shake adhering to 12-principles-of-animation (timing-under-300ms)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant PinDotsIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // High-frequency damped sine wave for realistic hardware shake
        final double offset = sin(_shakeAnimation.value * pi * 4) * 12 * (1 - _shakeAnimation.value);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.maxDigits, (index) {
              final isFilled = index < widget.pinLength;
              final isError = widget.hasError;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: isFilled ? 18 : 16,
                height: isFilled ? 18 : 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isError
                      ? const Color(0xFFEF4444)
                      : (isFilled ? colors.primary : Colors.transparent),
                  border: Border.all(
                    color: isError
                        ? const Color(0xFFEF4444)
                        : (isFilled
                            ? colors.primary
                            : colors.textSecondary.withValues(alpha: 0.3)),
                    width: 2,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: isError
                                ? const Color(0x66EF4444)
                                : colors.primaryGlow,
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
