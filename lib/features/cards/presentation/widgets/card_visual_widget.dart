import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/payment_card.dart';

class CardVisualWidget extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback? onCardTap;

  const CardVisualWidget({
    super.key,
    required this.card,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: _buildBoxDecoration(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Accents & Holographic Gradients
              Positioned.fill(
                child: _buildBackgroundOverlay(),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Brand & Type Badge + NFC Symbol
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getTypeColor().withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getTypeIcon(), size: 12, color: _getTypeColor()),
                                  const SizedBox(width: 6),
                                  Text(
                                    card.name.toUpperCase(),
                                    style: AppTextStyles.label(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // NFC & Signal
                        Row(
                          children: [
                            if (card.type == CardType.disposableGhost)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.6)),
                                ),
                                child: Text(
                                  'AUTO-ROLL CVV',
                                  style: AppTextStyles.label(
                                    color: const Color(0xFFF87171),
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            const Icon(
                              Icons.contactless_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Middle Row: Metallic EMV Chip
                    Row(
                      children: [
                        _buildEmvChip(),
                        const SizedBox(width: 12),
                        if (card.type == CardType.metalPhysical)
                          Text(
                            'TUNGSTEN METAL',
                            style: AppTextStyles.label(
                              color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),

                    // Card Number
                    Text(
                      card.displayCardNumber,
                      style: AppTextStyles.cardNumber(color: Colors.white).copyWith(
                        fontSize: 18,
                        letterSpacing: 2.5,
                      ),
                    ),

                    // Bottom Row: Holder Name, Expiry, & Brand Emblem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARDHOLDER',
                              style: AppTextStyles.label(
                                color: Colors.white54,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.cardholderName,
                              style: AppTextStyles.bodyMedium(
                                color: Colors.white,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPIRES',
                              style: AppTextStyles.label(
                                color: Colors.white54,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.expiry,
                              style: AppTextStyles.monospace(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        _buildBrandLogo(),
                      ],
                    ),
                  ],
                ),
              ),

              // Frosted Ice Overlay when Locked/Frozen
              if (card.isFrozen)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  color: Color(0xFF38BDF8),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'CARD FROZEN & LOCKED',
                                style: AppTextStyles.label(
                                  color: const Color(0xFFE0F2FE),
                                  fontSize: 12,
                                ).copyWith(letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Authorizations are temporarily blocked',
                                style: AppTextStyles.bodySmall(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    switch (card.type) {
      case CardType.metalPhysical:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0B0F19),
              Color(0xFF131B2E),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.4),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        );

      case CardType.virtualDebit:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF064E3B),
              Color(0xFF022C22),
              Color(0xFF090D16),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF00E599).withValues(alpha: 0.45),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E599).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );

      case CardType.disposableGhost:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF311042),
              Color(0xFF1E1B4B),
              Color(0xFF0F172A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFFA855F7).withValues(alpha: 0.45),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }

  Widget _buildBackgroundOverlay() {
    switch (card.type) {
      case CardType.metalPhysical:
        return CustomPaint(
          painter: _BrushedMetalMeshPainter(),
        );
      case CardType.virtualDebit:
        return CustomPaint(
          painter: _CyberGridPainter(color: const Color(0xFF00E599).withValues(alpha: 0.08)),
        );
      case CardType.disposableGhost:
        return CustomPaint(
          painter: _CyberGridPainter(color: const Color(0xFFA855F7).withValues(alpha: 0.1)),
        );
    }
  }

  Widget _buildEmvChip() {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDF7A),
            Color(0xFFD4AF37),
            Color(0xFF996515),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    if (card.brand == CardBrand.visa) {
      return Text(
        'VISA',
        style: AppTextStyles.heading2(
          color: Colors.white,
        ).copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      // Mastercard Interlocking Circles
      return SizedBox(
        width: 38,
        height: 24,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEB001B),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _getTypeColor() {
    switch (card.type) {
      case CardType.metalPhysical:
        return const Color(0xFFE2E8F0);
      case CardType.virtualDebit:
        return const Color(0xFF00E599);
      case CardType.disposableGhost:
        return const Color(0xFFA855F7);
    }
  }

  IconData _getTypeIcon() {
    switch (card.type) {
      case CardType.metalPhysical:
        return Icons.credit_card_rounded;
      case CardType.virtualDebit:
        return Icons.smartphone_rounded;
      case CardType.disposableGhost:
        return Icons.shield_moon_rounded;
    }
  }
}

class _BrushedMetalMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 16) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 1.2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CyberGridPainter extends CustomPainter {
  final Color color;
  _CyberGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
