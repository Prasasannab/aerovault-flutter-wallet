import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/virtual_card.dart';
import '../../domain/entities/wallet_account.dart';

/// 3D Flippable Platinum Neobank Virtual Card
/// Adheres strictly to ISO/IEC 7810 ID-1 (1.586:1) banking standard with specular lighting
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

    return AspectRatio(
      aspectRatio: 1.586, // ISO/IEC 7810 ID-1 Banking Standard Ratio
      child: AnimatedBuilder(
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
      ),
    );
  }

  /// Front Face: Platinum Luxury Obsidian (Dark) / Pearl Titanium (Light) Card
  Widget _buildFront(BuildContext context, NumberFormat currencyFormatter) {
    final isHidden = widget.account.isBalanceHidden;
    final isFrozen = widget.card.isFrozen;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isFrozen
              ? const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                )
              : (isDark
                  ? const LinearGradient(
                      begin: Alignment(-0.9, -1.0),
                      end: Alignment(0.9, 1.0),
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                      colors: [
                        Color(0xFF1D2635), // Brushed obsidian highlight
                        Color(0xFF0D141F), // Deep core
                        Color(0xFF172230), // Specular light reflection
                        Color(0xFF090E17), // Deep core
                        Color(0xFF141F2B), // Edge sheen
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment(-0.9, -1.0),
                      end: Alignment(0.9, 1.0),
                      stops: [0.0, 0.25, 0.55, 1.0],
                      colors: [
                        Color(0xFFFFFFFF), // Apple Card Pearl Titanium
                        Color(0xFFF8FAFC),
                        Color(0xFFF1F5F9),
                        Color(0xFFE2E8F0),
                      ],
                    )),
          border: Border.all(
            color: isFrozen
                ? AppColors.error.withValues(alpha: 0.5)
                : (isDark ? const Color(0x4400E599) : const Color(0x4000B075)),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isFrozen
                  ? AppColors.errorGlow
                  : (isDark ? AppColors.emeraldGlow : const Color(0x1F000000)),
              blurRadius: 26,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Specular Diagonal Light Streak (Metallic luxury gloss)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0, -1.0),
                      end: Alignment(1.0, 1.0),
                      stops: [0.0, 0.22, 0.42, 1.0],
                      colors: [
                        Color(0x28FFFFFF),
                        Color(0x0AFFFFFF),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle Radial Spotlight Glow
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isFrozen ? const Color(0x33FF4D4F) : const Color(0x2B00E599),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Card Content Elements
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Top Bar: EMV Chip, Contactless Wave, and Privacy Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildEmvChip(),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.contactless_rounded,
                              color: isDark ? const Color(0xCCFFFFFF) : const Color(0xFF334155),
                              size: 20,
                            ),
                            if (isFrozen) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorGlow,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.error, width: 0.8),
                                ),
                                child: Text(
                                  'CARD FROZEN',
                                  style: AppTextStyles.label(color: AppColors.error, fontSize: 8.5),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Balance Privacy Toggle Pill
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onToggleBalanceVisibility();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x1F00E599) : const Color(0x1A00B075),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0x4000E599) : const Color(0x3300B075),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: isDark ? AppColors.emerald : AppColors.emeraldDark,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isHidden ? 'Show' : 'Hide',
                                  style: AppTextStyles.label(
                                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. Center: Card Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AeroVault Platinum Balance',
                          style: AppTextStyles.label(
                            color: isDark ? const Color(0x99FFFFFF) : const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: isHidden
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            currencyFormatter.format(widget.account.totalPortfolioBalanceUsd),
                            style: AppTextStyles.balanceDisplay(
                              fontSize: 27,
                              color: isFrozen
                                  ? AppColors.textMuted
                                  : (isDark ? AppColors.textPrimary : const Color(0xFF0F172A)),
                            ),
                          ),
                          secondChild: Text(
                            '\$••••••••••',
                            style: AppTextStyles.balanceDisplay(
                              fontSize: 27,
                              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 3. Bottom: Card Number & Tier Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.card.cardNumberMasked,
                              style: AppTextStyles.cardNumber(
                                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                              ).copyWith(
                                fontSize: 13.5,
                                letterSpacing: 2.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.account.holderName.toUpperCase(),
                              style: AppTextStyles.label(
                                color: isDark ? const Color(0xB3FFFFFF) : const Color(0xFF475569),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.card.cardTier,
                              style: AppTextStyles.label(
                                color: isFrozen
                                    ? AppColors.textMuted
                                    : (isDark ? AppColors.emerald : AppColors.emeraldDark),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'EXP ${widget.card.expiry}',
                              style: AppTextStyles.label(
                                color: isDark ? const Color(0x80FFFFFF) : const Color(0xFF64748B),
                                fontSize: 9.5,
                              ),
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

  /// Authentic Brass Gold EMV Smart Chip with Micro-Circuits
  Widget _buildEmvChip() {
    return Container(
      width: 36,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE082),
            Color(0xFFD4AF37),
            Color(0xFFA67C1E),
            Color(0xFFE5C07B),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Center horizontal circuit line
          Center(
            child: Container(
              width: double.infinity,
              height: 0.8,
              color: const Color(0x55000000),
            ),
          ),
          // Center vertical circuit line
          Center(
            child: Container(
              width: 0.8,
              height: double.infinity,
              color: const Color(0x55000000),
            ),
          ),
          // Internal central contact core
          Center(
            child: Container(
              width: 14,
              height: 11,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x55000000), width: 0.8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Back Face: Magnetic Stripe, CVV, Spending Limits & Instant Freeze Controls
  Widget _buildBack(BuildContext context) {
    final isFrozen = widget.card.isFrozen;
    final isDark = context.isDarkMode;
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: isDark ? const Color(0x26FFFFFF) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : const Color(0x18000000),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            // Black Magnetic Stripe
            Container(
              height: 38,
              width: double.infinity,
              color: const Color(0xFF070B12),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Signature panel & CVV
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 150,
                        height: 26,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AUTHORIZED SIGNATURE',
                          style: AppTextStyles.label(
                            color: Colors.grey.shade600,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0x44FFFFFF)),
                        ),
                        child: Text(
                          'CVV  842',
                          style: AppTextStyles.label(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Daily Spending Limit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Limit',
                        style: AppTextStyles.label(color: AppColors.textMuted, fontSize: 10),
                      ),
                      Text(
                        '${currencyFormatter.format(widget.card.currentSpend)} / ${currencyFormatter.format(widget.card.spendingLimit)}',
                        style: AppTextStyles.label(
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.card.spendPercentage.clamp(0.0, 1.0),
                      backgroundColor: const Color(0x22FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFrozen ? AppColors.error : AppColors.emerald,
                      ),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Instant Card Freeze Control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isFrozen ? Icons.lock_rounded : Icons.lock_open_rounded,
                            size: 14,
                            color: isFrozen ? AppColors.error : AppColors.emerald,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isFrozen ? 'Card Frozen' : 'Card Active',
                            style: AppTextStyles.bodySmall(
                              color: isFrozen ? AppColors.error : AppColors.emerald,
                            ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.72,
                        child: Switch(
                          value: isFrozen,
                          activeThumbImage: null,
                          activeThumbColor: AppColors.error,
                          inactiveThumbColor: AppColors.emerald,
                          inactiveTrackColor: const Color(0x22FFFFFF),
                          onChanged: (val) {
                            HapticFeedback.heavyImpact();
                            widget.onToggleCardFreeze(val);
                          },
                        ),
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
