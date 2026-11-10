import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/payment_card.dart';

class SensitiveCardDetailsWidget extends StatefulWidget {
  final PaymentCard card;
  final VoidCallback onToggleReveal;

  const SensitiveCardDetailsWidget({
    super.key,
    required this.card,
    required this.onToggleReveal,
  });

  @override
  State<SensitiveCardDetailsWidget> createState() => _SensitiveCardDetailsWidgetState();
}

class _SensitiveCardDetailsWidgetState extends State<SensitiveCardDetailsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
  }

  @override
  void didUpdateWidget(covariant SensitiveCardDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isSensitiveRevealed && !oldWidget.card.isSensitiveRevealed) {
      _startAutoMaskCountdown();
    } else if (!widget.card.isSensitiveRevealed && oldWidget.card.isSensitiveRevealed) {
      _cancelAutoMaskCountdown();
    }
  }

  void _startAutoMaskCountdown() {
    _timerController.reset();
    _timerController.forward();
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && widget.card.isSensitiveRevealed) {
        widget.onToggleReveal();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: context.colors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Card credentials automatically hidden for security.',
              style: AppTextStyles.bodySmall(color: context.colors.textPrimary),
            ),
          ),
        );
      }
    });
  }

  void _cancelAutoMaskCountdown() {
    _timerController.reset();
    _autoHideTimer?.cancel();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRevealTap() async {
    HapticFeedback.lightImpact();

    if (widget.card.isSensitiveRevealed) {
      // Hide immediately
      _cancelAutoMaskCountdown();
      widget.onToggleReveal();
      return;
    }

    // Biometric authorization before revealing sensitive financial secrets
    final biometric = sl<BiometricService>();
    final authenticated = await biometric.authenticate(
      localizedReason: 'Authorize FaceID to reveal full card credentials',
    );

    if (authenticated) {
      HapticFeedback.mediumImpact();
      widget.onToggleReveal();
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Biometric verification failed. Card details withheld.',
              style: AppTextStyles.bodySmall(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _copyCardNumber() {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: widget.card.fullNumber.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.primary.withValues(alpha: 0.5)),
        ),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: context.colors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              'Full card number copied to secure clipboard',
              style: AppTextStyles.bodySmall(color: context.colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRevealed = widget.card.isSensitiveRevealed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRevealed
              ? context.colors.primary.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isRevealed ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      size: 16,
                      color: isRevealed ? context.colors.primary : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'CARD SECRETS',
                        style: AppTextStyles.label(
                          color: isRevealed ? context.colors.primary : colors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _handleRevealTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isRevealed
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isRevealed
                          ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                          : colors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRevealed ? Icons.visibility_off_rounded : Icons.fingerprint_rounded,
                        size: 13,
                        color: isRevealed ? const Color(0xFFEF4444) : colors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isRevealed ? 'Hide' : 'Reveal via FaceID',
                        style: AppTextStyles.label(
                          color: isRevealed ? const Color(0xFFEF4444) : colors.primary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card Details Grid
          Row(
            children: [
              // Card Number
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Number', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.displayCardNumber,
                      style: AppTextStyles.monospace(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Expiry
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expiry', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.expiry,
                      style: AppTextStyles.monospace(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // CVV
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CVV / CVC', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.displayCvv,
                      style: AppTextStyles.monospace(
                        color: isRevealed ? context.colors.primary : colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Copy Button (Only if revealed)
              if (isRevealed)
                IconButton(
                  onPressed: _copyCardNumber,
                  icon: Icon(Icons.copy_rounded, size: 18, color: colors.primary),
                  tooltip: 'Copy Number',
                ),
            ],
          ),

          // 30s Countdown Timer Bar if Revealed
          if (isRevealed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 1.0 - _timerController.value,
                          minHeight: 3,
                          backgroundColor: colors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, _) {
                    final remainingSeconds = ((1.0 - _timerController.value) * 30).ceil();
                    return Text(
                      '${remainingSeconds}s auto-mask',
                      style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
