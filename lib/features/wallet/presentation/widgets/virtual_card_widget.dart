import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/virtual_card.dart';
import '../../domain/entities/wallet_account.dart';

/// 3D Flippable Platinum Neobank Virtual Card
/// Adheres to impeccable luxury fintech styling and 60fps micro-animations
class VirtualCardWidget extends StatefulWidget {
  final WalletAccount account;
  final VirtualCard card;
  final VoidCallback onToggleBalanceVisibility;
  final ValueChanged<bool> onToggleCardFreeze;

  const VirtualCardWidget({
    super.key,
    required this.account,
    required this.card,
    required this.onToggleBalanceVisibility,
    required this.onToggleCardFreeze,
  });

  @override
  State<VirtualCardWidget> createState() => _VirtualCardWidgetState();
}

class _VirtualCardWidgetState extends State<VirtualCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutCubic,
      ),
    )..addListener(() {
        final isHalfWay = _flipController.value >= 0.5;
        if (isHalfWay != _showBack) {
          setState(() {
            _showBack = isHalfWay;
          });
        }
      });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * math.pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // Realistic perspective depth
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: _showBack
              ? Transform(
                  // Counter-rotate back side so text is not mirrored
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _buildBack(context),
                )
              : _buildFront(context, currencyFormatter),
        );
      },
    );
  }

  /// Front Face: Platinum Luxury Obsidian Card
  Widget _buildFront(BuildContext context, NumberFormat currencyFormatter) {
    final isHidden = widget.account.isBalanceHidden;
    final isFrozen = widget.card.isFrozen;

    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        height: 215,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isFrozen
              ? const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                )
              : AppColors.platinumCardGradient,
          border: Border.all(
            color: isFrozen ? AppColors.error.withValues(alpha: 0.4) : const Color(0x3300E599),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isFrozen ? AppColors.errorGlow : AppColors.emeraldGlow,
              blurRadius: 28,
              spreadRadius: -6,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle background geometric glow
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isFrozen ? const Color(0x33FF4D4F) : const Color(0x2600E599),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Container(
                                  width: 22,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black45, width: 0.8),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.wifi,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            if (isFrozen) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorGlow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error, width: 0.8),
                                ),
                                child: Text(
                                  'CARD FROZEN',
                                  style: AppTextStyles.label(color: AppColors.error, fontSize: 9),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Balance Privacy Toggle
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onToggleBalanceVisibility();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.emerald,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isHidden ? 'Show' : 'Hide',
                                  style: AppTextStyles.label(color: AppColors.textPrimary, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Card Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AeroVault Platinum Balance',
                          style: AppTextStyles.label(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: isHidden
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            currencyFormatter.format(widget.account.totalPortfolioBalanceUsd),
                            style: AppTextStyles.balanceDisplay(
                              fontSize: 30,
                              color: isFrozen ? AppColors.textMuted : AppColors.textPrimary,
                            ),
                          ),
                          secondChild: Text(
                            '••••••••••••',
                            style: AppTextStyles.balanceDisplay(
                              fontSize: 30,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Card Bottom Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.card.cardNumberMasked,
                              style: AppTextStyles.cardNumber(),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.account.holderName.toUpperCase(),
                              style: AppTextStyles.label(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.card.cardTier,
                              style: AppTextStyles.label(
                                color: isFrozen ? AppColors.textMuted : AppColors.emerald,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'EXP ${widget.card.expiry}',
                              style: AppTextStyles.label(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Back Face: Magnetic Stripe, CVV, Spending Limits & Instant Freeze Controls
  Widget _buildBack(BuildContext context) {
    final isFrozen = widget.card.isFrozen;
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        height: 215,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0x26FFFFFF),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Black Magnetic Stripe
            Container(
              height: 42,
              width: double.infinity,
              color: const Color(0xFF070B12),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Signature panel & CVV
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 170,
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.account.holderName,
                          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CVV 842',
                          style: AppTextStyles.label(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Monthly Spending Limit Tracker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Spending Limit', style: AppTextStyles.label(color: AppColors.textMuted)),
                      Text(
                        '${currencyFormatter.format(widget.card.currentSpend)} / ${currencyFormatter.format(widget.card.spendingLimit)}',
                        style: AppTextStyles.label(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.card.spendPercentage,
                      minHeight: 5,
                      backgroundColor: const Color(0x33FFFFFF),
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Freeze Switch on Card Back
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFrozen ? 'Unfreeze Card' : 'Freeze Card',
                        style: AppTextStyles.bodySmall(
                          color: isFrozen ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                      Switch.adaptive(
                        value: isFrozen,
                        activeThumbColor: AppColors.error,
                        onChanged: (val) {
                          HapticFeedback.mediumImpact();
                          widget.onToggleCardFreeze(val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
